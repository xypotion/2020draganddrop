--it works! now, what would happen in a BE grid? imagine using a QUEUE to line up events
--1. thing is grabbed and the mouse is released. make sure (1) it can be moved, (2) its destination is valid; (3) check the same two things for the other item if it's a swap
--2. IF dest is empty, just drop it in; no animation (actuation);
	-- ELSE it's swapping with something, so actuate both items swapping with each other
--3. actually place the item in the grid cell; swap if necessary; this should maybe be done before the actuation
--4. re-calculate stats/whatever. probably no animation here, but do update display. actuate if you want to be fancy, but make it quick
--5. re-calculate all syncs IF THERE WAS A CHANGE TO THEM. probably check this ahead of time. 
--		if there wasn't, then account for them again (multipliers, whatever) silently
--		if there was, then wipe them now and show base stats/whatever. actuate if you want to be fancy...
--6. if syncs have to be demonstrated, quickly animate each line being drawn, then update sync display
--all of this should happen fairly quickly. don't make player wait around while sync lines are being redrawn... like a second or two at most
--ooh, maybe even click/tap to skip the animation? probably not hard to do. and/or player can configure to be instantaneous

require "eventSetQueue"
require "pathfinding"

function love.load()
	math.randomseed(os.time())
	
	-- make the GRID
	grid = {}
	for y=1, 3 do
		grid[y] = {}
		for x=1, 3 do
			local r, g, b = math.random(), math.random(), math.random()
			grid[y][x] = {
				mouseOver = false,
				bgColor = {r, g, b, 0.25},
				bgHoverColor = {r, g, b, 0.5}
			}
		end
	end

	gridOffsetX, gridOffsetY = 144, 144
	
	initEventQueueSystem()

	--ADD CONTENTS to the grid + track in things table
	-- things = {}
	for y, row in ipairs(grid) do
		for x, cell in ipairs(row) do
			local t = {class = "clear"}
			
			--add t to things list...
			-- table.insert(things, t)
			
			--...but more importantly, add to grid
			cell.contents = t
		end
	end
	
	grid[1][1].contents = {
		class = "hero",
		color = {1,1,1,1},
		fadeColor = {1,1,1,0.5},
		message = "hero?",
		yOffset = 0,
		xOffset = 0
	}
		
	queue(gridOpEvent(grid, "add obstacles", {threshold = 0.2}))
	
	grabbedThing = nil
	
	cellSize = 72
	
	longPressTime = 0.5
	mouseDownTimer = 0
	mouseDownAtX, mouseDownAtY = 0, 0 --not sure if necessary
	mouseStillDown = false
	mouseHasntMovedFar = false
	
	--debuggy
	grid = mapAllPathsFromHero(grid) --TODO might rather make this "mapAllPathsFrom", then provide coordinates. also maybe a mode?
	--also TODO shouldn't there be a way to not make this return things
	gameMode = "map" --TODO shouldn't be necessary! remove & simplify
	hoveredCell = nil
		
	-- tablePrint(grid)
end

function love.update(dt)
	eventProcessing(dt)
	
	--still maybe doing a long press?
	if mouseHasntMovedFar and grabbedThing then
		local dx, dy = love.mouse.getX() - mouseDownAtX, love.mouse.getY() - mouseDownAtY
		
		if dx * dx + dy * dy > 100 then
			mouseHasntMovedFar = false
			mouseDownTimer = 0
		end
	end
	
	--yes, so far still doing a long press
	--TODO this block can almost definitely be consolidated with the above one
	if mouseHasntMovedFar then
		--keep counting the long-press timer up
		if love.mouse.isDown(1) then
			mouseDownTimer = mouseDownTimer + dt
		end
	
		--done counting! do that long press 
		--also reset stuff so we don't repeatedly do long-press stuff
		if mouseDownTimer >= longPressTime and not mouseStillDown then
			longPressEventAt(love.mouse.getPosition())
			
			mouseDownTimer = 0
			mouseStillDown = false
			mouseHasntMovedFar = false
			grabbedThing = nil
		end
	end
end

function love.draw()	
	--grid cells
	for y=1, 3 do
		for x=1, 3 do
			local cell = grid[y][x]
			if cell.mouseOver then
				setColor(cell.bgHoverColor)
			else
				setColor(cell.bgColor)
			end
			love.graphics.rectangle("fill", (x-1)*cellSize+1+gridOffsetX, (y-1)*cellSize+1+gridOffsetY, cellSize-2, cellSize-2)
		end
	end
	
	white()
	
	if gameMode == "map" then
		--"hero"
		-- love.graphics.circle("fill", (currentCell.x-0.5)*cellSize + gridOffsetX, (currentCell.y-0.5)*cellSize + gridOffsetY, cellSize*0.45)
		
		--obstacles
		for y, row in pairs(grid) do
			for x, c in pairs(row) do
				-- if c.obstacle then
					setColor(0,0,0)
					-- love.graphics.circle("fill", (x-0.5)*cellSize + gridOffsetX, (y-0.5)*cellSize + gridOffsetY, cellSize*0.45)
					if c.contents and c.contents.class ~= "clear" then
						drawCellContents(c.contents, (y-0.5)*cellSize + gridOffsetY, (x-0.5)*cellSize + gridOffsetX)
					end
				-- end
			end
		end
		
		white()
		
		--path to currently hovered destination
		if hoveredCell then
			for i, step in pairs(grid[hoveredCell.y][hoveredCell.x].pathFromHero) do
				love.graphics.circle("line", (step.x-0.5)*cellSize + gridOffsetX, (step.y-0.5)*cellSize + gridOffsetY, cellSize*0.45)
			end
			
		end
	else
		--things in grid
		for y=1, 3 do
			for x=1, 3 do
				if grid[y][x].contents then
					love.graphics.setColor(grid[y][x].contents.color)
					love.graphics.circle("fill", (x-0.5)*cellSize + gridOffsetX, (y-0.5)*cellSize + gridOffsetY, cellSize*0.45)
				end
			end
		end
	
		--grabbedThing
		if grabbedThing then
			local mx, my = love.mouse.getPosition()
			setColor(grabbedThing.item.fadeColor)
			love.graphics.circle("fill", mx - grabbedThing.relMouseX + cellSize/2, my - grabbedThing.relMouseY + cellSize/2, cellSize*0.45)
		end
	end
		
	white()
end


-----------------------------------------------------------------------------------------------------------

function drawStage()
end

function drawCellContents(obj, screenY, screenX)
	setColor(obj.color)
	love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.45)
end

-----------------------------------------------------------------------------------------------------------


--called for queueing move events after input is given
function moveThingAtYX(y, x, dy, dx)
	local ty, tx = y + dy, x + dx
	
	--max = the number of movement frames
	local max = 2
	
	for k = max - 1, 0, -1 do
		push(moveFrames, {pose = "idle", yOffset = dy * -(cellSize * k / max), xOffset = dx * -(cellSize * k / max)})
	end
	
	--queue pose and cell ops
	queueSet({
		cellSwapEvent(grid, y, x, ty, tx), --eventually this won't work, but ok for now
		spriteMoveEvent(grid, ty, tx, moveFrames)
	})
	
	processNow()
end


-----------------------------------------------------------------------------------------------------------


function love.mousepressed(mx, my, button)
	local mCellX, mCellY = math.floor((mx-gridOffsetX+cellSize)/cellSize), math.floor((my-gridOffsetY+cellSize)/cellSize)
	mouseDownAtX, mouseDownAtY = mx, my
	
	--if we're clicking in the grid and there's an item there, "grab" it
	if grid[mCellY] and grid[mCellY][mCellX] and grid[mCellY][mCellX].contents then
		grabbedThing = {
			item = grid[mCellY][mCellX].contents,
			relMouseY = my - cellSize * (mCellY - 1) - gridOffsetY, --to prevent the graphic from jumping to a weird place near the cursor when grabbed
			relMouseX = mx - cellSize * (mCellX - 1) - gridOffsetX,
			originY = mCellY,
			originX = mCellX
		}
		
		mouseHasntMovedFar = true
	end
end

function love.mousereleased(mx, my, button)
	local mCellX, mCellY = math.floor((mx-gridOffsetX+cellSize)/cellSize), math.floor((my-gridOffsetY+cellSize)/cellSize)
	
	if gameMode == "map" then
		if cellExistsAt(mCellX, mCellY) then
			
			--is this somewhere that can be walked to?
			if grid[mCellY][mCellX].pathFromHero then
				--TODO make this more readable
				local starty = findHeroLocationInGrid(grid)
				for i, step in ipairs(grid[mCellY][mCellX].pathFromHero) do			
					moveThingAtYX(starty.y, starty.x, step.y - starty.y, step.x - starty.x)
					
					starty = step
				end
				
				--debug. just clear obstacles and then add some
				queue(gridOpEvent(grid, "clear obstacles"))
				queue(gridOpEvent(grid, "add obstacles", {threshold = 0.2}))
				
				--then once done walking, remap the paths
				queue(gridOpEvent(grid, "remap"))
			end
		end
	else
		if grabbedThing and grabbedThing.item then
			if cellExistsAt(mCellX, mCellY) then
				queue(cellSwapEvent(grid, mCellY, mCellX, grabbedThing.originY, grabbedThing.originX))
			end
		
			grabbedThing = nil
			processNow()		
		end
	
		-- grabbedThing = nil
		-- mouseDownAtX, mouseDownAtY = 0, 0 --i really feel like there should be a more efficient way to do this...
		mouseDownTimer = 0
		mouseStillDown = false
		mouseHasntMovedFar = false
	
		processNow()
	end
end

function love.mousemoved(x,y)
	local mCellX, mCellY = math.floor((x-gridOffsetX+cellSize)/cellSize), math.floor((y-gridOffsetY+cellSize)/cellSize)

	--are we now hovering over a grid cell?
	--note that this will not really be a thing when the game is for touchscreens...
	hoveredCell = nil
	
	for y=1, 3 do
		for x=1, 3 do
			if y == mCellY and x == mCellX then
				grid[y][x].mouseOver = true
				hoveredCell = {y = y, x = x}
			else
				grid[y][x].mouseOver = false
			end
		end
	end
end

function longPressEventAt(mx, my)
	local t = getTopThingAtPos(mx, my)
	
	print(t.message)
	
	local r, g, b = math.random(), math.random(), math.random()
	t.color = {r, g, b, 1}
	t.fadeColor = {r, g, b, 0.5}
	t.message = "my darkness is this strong: "..(1/(r+g+b))
end

--TODO maybe change this to just take cell coords
function getTopThingAtPos(mx, my)
	-- for thing in pairs(clickableThings) do
	--	...
	-- end
	--wait, of course it's not gonna be this easy. hmmm
	--...i still feel like this is the better way, though. TODO some system that puts all drawable things in a list like this. i guess? unless it's 100% not necessary
	
	--TODO yeah, this can definitely be abstracted, since other things use this
	if my >= gridOffsetY and my <= cellSize * 3 + gridOffsetY and mx >= gridOffsetX and mx <= cellSize * 3 + gridOffsetX then		
		local cx, cy = math.floor((mx-gridOffsetX+cellSize)/cellSize), math.floor((my-gridOffsetY+cellSize)/cellSize)
		
		if grid[cy] and grid[cy][cx] and grid[cy][cx].contents then
			return grid[cy][cx].contents
		end
	end
end

--basically all debug functions! :P
function love.keypressed(key)
	if key == "escape" then love.event.quit() end
	
	if key == "p" then
		tablePrint(currentEvents)
	end
	
	if key == "s" then
		for i = 1, 27 do
			queue(cellSwapEvent(grid, math.random(3), math.random(3), math.random(3), math.random(3)))
		end
	end
	
	if key == "d" then
		tablePrint(findHeroLocationInGrid(grid))
	end
end

--not sure if this is really that helpful...
function cellExistsAt(x, y)
	if grid[y] and grid[y][x] then
		return true
	else
		return false
	end
end

--TODO decide you need this or not. not sure if it's necessary when you can just do grid[y][x]
--copied from HDBS:
-- function cellAt(y, x)
-- 	-- if stage.field[y] then
-- 	-- 	return stage.field[y][x]
-- 	if grid[y] and grid[y][x] and grid[y][x].contents then
-- 		return grid[y][x]
-- 	else
-- 		return nil
-- 	end
-- end

-- function itemAt(x, y)
-- 	if grid[y] and grid[y][x] and grid[y][x].contents then
-- 		return grid[y][x].contents
-- 	else
-- 		return nil
-- 	end
-- end


-----------------------------------------------------------------------------------------------------------


function white()
	love.graphics.setColor(1,1,1)
end

function setColor(r,g,b,a)
	if not a then a = 1 end
	
	love.graphics.setColor(r,g,b,a)
end

--mutates the input, so ONLY use this in the form foo = shuffle(foo)
function shuffle(arr)
	local new = {}
	
	for i = 1, table.getn(arr) do
		new[i] = table.remove(arr, math.random(table.getn(arr)))
	end
	
	return new
end

-- function clear()
-- 	return {class = "clear"}
-- end
--
-- function empty()
-- 	return {contents = clear()}
-- end

function empty(t)
	local e = true
	for k, v in pairs(t) do
		e = false
	end
	
	return e
end

function peek(q)
	return q[1]
end

--why the hell is this so complicated? TODO
function pop(q)
	local item = q[1]
	
	for i = 2, table.getn(q) do
		q[i - 1] = q[i]
	end
	
	q[table.getn(q)] = nil

	return item
end

--TODO maybe find better names for these two functions...
function push(q, item)
	table.insert(q, item)
end

--basically just inserting at the other end from push()
function reversePush(q, item)
	table.insert(q, 1, item)
end

--an old debug-helper function i made in 2014 :)
--reminder: never pass _G here, or other weird/global/self-nested tables here 
function tablePrint(table, offset)
	offset = offset or "  "
	
	for k,v in pairs(table) do
		if type(v) == "table" then
			print(offset.."sub-table ["..k.."]:")
			tablePrint(v, offset.."  ")
		else
			print(offset.."["..k.."] = "..tostring(v))
		end
	end	
end
