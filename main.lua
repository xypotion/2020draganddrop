--[[
sort of hilarious that this doesn't do dragging and dropping anymore, and it never related to matching :P

things that would be good to do next
- multiple grids; nav on top, drag & drop on bottom
- "inventory" or "drawer" of items to drag into/between grids. maybe can drag obstacles from bottom to top? :)
- obs-tacular pathing, like different ways of pathing near/around/over different types of things
- canvases + click input
- build & test this shit on android
  - ugh, and start building a quicksave framework with auto-serialize or recursive table-zipping... but also check forums to see if there's a better way. :/
]]


require "eventSetQueue"
require "pathfinding"
require "hero"
require "helpers"
require "island"

function love.load()
  math.randomseed(os.time())

  love.window.setTitle("<3")

  cellSize, overworldZoom = 18, 4
  
	overworldCanvas = love.graphics.newCanvas(cellSize * 5, cellSize * 5)
  overworldCanvas:setFilter("nearest")
  
  love.window.setMode(cellSize * overworldZoom * 5, cellSize * overworldZoom * 9)


  initEventQueueSystem()

  -- make the GRIDS
  -- GRIDS = {}
  -- GRIDS.debug = initDebugGrid()
  -- GRIDS.debug.offsetX, GRIDS.debug.offsetY = cellSize, cellSize
  -- GRIDS.debug.offsetX, GRIDS.debug.offsetY = 0, 0 --cellSize, cellSize

  -- tablePrint(allCellsInGrid(GRIDS.debug))

  --this is not elegant (you're mapping twice at boot), but it's debug junk anyway. doesn't matter
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "block", threshold = 0.1}))
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "npc", threshold = 0.1}))
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "danger", threshold = 0.1}))
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "item", threshold = 0.1})) --TODO document these in gridOps before deleting. lol
  -- queue(gridOpEvent(GRIDS.debug, "remap"))


  --init island and CIA + NIA ("current " and "next island area")
  currentIsland = initIsland()
  CIA = currentIsland[currentIsland.areaNumbersReference[1].y][currentIsland.areaNumbersReference[1].x]
  NIA = nil
  
  -- tablePrint(CIA)
  
  queue(gridOpEvent(CIA, "add obstacles", {type = "item", threshold = 0.1}))
  queue(gridOpEvent(CIA, "remap"))
  
  CIA[3][3].contents = {
    class = "hero",
    color = {1,1,1,1},
    fadeColor = {1,1,1,0.5},
    message = "hero?",
    yOffset = 0,
    xOffset = 0
  }
  
  CIA = mapAllPathsFromHero(CIA)


--  grabbedThing = nil

  longPressTime = 0.5
  mouseDownTimer = 0
  mouseDownAtX, mouseDownAtY = 0, 0 --not sure if necessary
  mouseStillDown = false
  mouseHasntMovedFar = false

  --debuggy
  -- GRIDS.debug = mapAllPathsFromHero(GRIDS.debug) --TODO might rather make this "mapAllPathsFrom", then provide coordinates. also maybe a mode?

  --also TODO shouldn't there be a way to not make this return things
  gameMode = "debug" --TODO shouldn't be necessary! remove & simplify
  hoveredCell = nil

  softOscillator = 1
  oscillatorCounter = 0
  TAU = math.pi * 2


  -- tablePrint(GRIDS)


  --pretending i know how the hero object will be structured
  initHERO()
  -- tablePrint(HERO)
end

function initDebugGrid()
  local grid = {}

  local debugGridSize = 5

  --build out the grid itself & initialize cells 
  for y=1, debugGridSize do
    grid[y] = {}
    for x=1, debugGridSize do
      local r, g, b = math.random(), math.random(), math.random()
      grid[y][x] = {
        mouseOver = false,
        bgColor = {r, g, b, 0.25},
        bgHoverColor = {r, g, b, 0.5}
      }
    end
  end

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

  --create hero and place at at 1,1
  grid[1][1].contents = {
    class = "hero",
    color = {1,1,1,1},
    fadeColor = {1,1,1,0.5},
    message = "hero?",
    yOffset = 0,
    xOffset = 0
  }

  return grid
end

function love.update(dt)
  oscillatorCounter = oscillatorCounter + dt * 5 % TAU
  softOscillator = 0.25 + math.sin(oscillatorCounter) * 0.0625

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
  
  
  love.graphics.setCanvas(overworldCanvas)  
  love.graphics.clear(0,0,0,1)
  
  --grid cells
  -- for y=1, 3 do
  -- 	for x=1, 3 do
  -- for k, v in ipairs(allCellsInGrid(GRIDS.debug)) do
  for k, v in ipairs(allCellsInGrid(CIA)) do
    -- local cell = GRIDS.debug[y][x]
    -- tablePrint(cell)
    if v.cell.mouseOver then
      setColor(v.cell.bgHoverColor)
    else
      setColor(v.cell.bgColor)
    end
    -- love.graphics.rectangle("fill", (v.x-1)*cellSize+1+GRIDS.debug.offsetX, (v.y-1)*cellSize+1+GRIDS.debug.offsetY, cellSize-2, cellSize-2)
    love.graphics.rectangle("fill", (v.x-1)*cellSize+1+CIA.offsetX, (v.y-1)*cellSize+1+CIA.offsetY, cellSize-2, cellSize-2)
  end
  -- end

  white()

  -- if gameMode == "map" then
  --"hero"
  -- love.graphics.circle("fill", (currentCell.x-0.5)*cellSize + GRIDS.debug.offsetX, (currentCell.y-0.5)*cellSize + GRIDS.debug.offsetY, cellSize*0.45)

  --obstacles
  -- for y, row in ipairs(GRIDS.debug) do
  for y, row in ipairs(CIA) do
    for x, c in ipairs(row) do
      -- if c.obstacle then
      setColor(0,0,0)
      -- love.graphics.circle("fill", (x-0.5)*cellSize + GRIDS.debug.offsetX, (y-0.5)*cellSize + GRIDS.debug.offsetY, cellSize*0.45)
      if c.contents and c.contents.class ~= "clear" then
        -- drawCellContents(c.contents, (y-0.5)*cellSize + GRIDS.debug.offsetY, (x-0.5)*cellSize + GRIDS.debug.offsetX)
        drawCellContents(c.contents, (y-0.5)*cellSize + CIA.offsetY, (x-0.5)*cellSize + CIA.offsetX)
      end
      -- end
    end
  end

  white()

  --path to currently hovered destination
  if hoveredCell then
    -- for i, step in pairs(GRIDS.debug[hoveredCell.y][hoveredCell.x].pathFromHero) do
    for i, step in pairs(CIA[hoveredCell.y][hoveredCell.x].pathFromHero) do
      -- love.graphics.circle("line", (step.x-0.5)*cellSize + GRIDS.debug.offsetX, (step.y-0.5)*cellSize + GRIDS.debug.offsetY, cellSize*0.45)
      love.graphics.circle("line", (step.x-0.5)*cellSize + CIA.offsetX, (step.y-0.5)*cellSize + CIA.offsetY, cellSize*0.45)
    end

  end
  -- else
  --things in grid		--
  -- for y=1, 3 do
  -- 	for x=1, 3 do
  -- 		if GRIDS.debug[y][x].contents and GRIDS.debug[y][x].contents.color then
  -- 			love.graphics.setColor(GRIDS.debug[y][x].contents.color)
  -- 			love.graphics.circle("fill", (x-0.5)*cellSize + GRIDS.debug.offsetX, (y-0.5)*cellSize + GRIDS.debug.offsetY, cellSize*0.45)
  -- 		end
  -- 	end
  -- end
  --
  -- --grabbedThing
  -- if grabbedThing then
  -- 	local mx, my = love.mouse.getPosition()
  -- 	-- tablePrint(grabbedThing)
  -- 	setColor(grabbedThing.item.fadeColor)
  -- 	love.graphics.circle("fill", mx - grabbedThing.relMouseX + cellSize/2, my - grabbedThing.relMouseY + cellSize/2, cellSize*0.45)
  -- end
  -- end

  white()
  
	--draw gameCanvas
	love.graphics.setCanvas()
	love.graphics.draw(overworldCanvas, 0, 0, 0, overworldZoom, overworldZoom)
end


-----------------------------------------------------------------------------------------------------------

function drawStage()
end

function drawCellContents(obj, screenY, screenX)
  setColor(obj.color)

  if obj.class == "block" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.5, 8)
  elseif obj.class == "danger" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize * 0.4, 4)
  elseif obj.class == "npc" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.35)
  elseif obj.class == "item" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.15)
  elseif obj.class == "hero" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize * softOscillator)
  end
  -- love.graphics.polygon("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.45)
end

-----------------------------------------------------------------------------------------------------------


--called for queueing move events after input is given
function moveThingAtYX(y, x, dy, dx)
  local ty, tx = y + dy, x + dx

  --max = the number of movement frames
  local max = 6
  local moveFrames = {}

  for k = max - 1, 0, -1 do
    push(moveFrames, {
        pose = "idle", 
        yOffset = dy * -(cellSize * k / max), 
        xOffset = dx * -(cellSize * k / max)
      })
  end

  --queue pose and cell ops
  -- queueSet({
  --     cellSwapEvent(GRIDS.debug, y, x, ty, tx), --eventually this won't work, but ok for now
  --     spriteMoveEvent(GRIDS.debug, ty, tx, moveFrames)
  --   })

  --queue pose and cell ops
  queueSet({
      cellSwapEvent(CIA, y, x, ty, tx), --eventually this won't work, but ok for now
      spriteMoveEvent(CIA, ty, tx, moveFrames)
    })

  processNow()
end


-----------------------------------------------------------------------------------------------------------


function love.mousepressed(mx, my, button)
  -- local mCellX, mCellY = math.floor((mx-GRIDS.debug.offsetX+cellSize)/cellSize), math.floor((my-GRIDS.debug.offsetY+cellSize)/cellSize)
  -- local mCellX, mCellY = math.floor((mx-CIA.offsetX+cellSize)/cellSize), math.floor((my-CIA.offsetY+cellSize)/cellSize)
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)
  
  mouseDownAtX, mouseDownAtY = mx, my

  --if we're clicking in the grid and there's an item there, "grab" it... TODO this sucks. clean it up
  -- if GRIDS.debug[mCellY] and GRIDS.debug[mCellY][mCellX] and GRIDS.debug[mCellY][mCellX].contents and GRIDS.debug[mCellY][mCellX].contents.class ~= "clear" then
  if CIA[mCellY] and CIA[mCellY][mCellX] and CIA[mCellY][mCellX].contents and CIA[mCellY][mCellX].contents.class ~= "clear" then
    grabbedThing = {
      -- item = GRIDS.debug[mCellY][mCellX].contents,
      item = CIA[mCellY][mCellX].contents,
      -- relMouseY = my - cellSize * (mCellY - 1) - GRIDS.debug.offsetY, --to prevent the graphic from jumping to a weird place near the cursor when grabbed
      -- relMouseX = mx - cellSize * (mCellX - 1) - GRIDS.debug.offsetX,
      relMouseY = my - cellSize * (mCellY - 1) - CIA.offsetY, --to prevent the graphic from jumping to a weird place near the cursor when grabbed
      relMouseX = mx - cellSize * (mCellX - 1) - CIA.offsetX,
      originY = mCellY,
      originX = mCellX
    }

    mouseHasntMovedFar = true
  end
end

--TODO prevent input from doing anything when an animation (event) is in progress!
function love.mousereleased(mx, my, button)
  -- local mCellX, mCellY = math.floor((mx-GRIDS.debug.offsetX+cellSize)/cellSize), math.floor((my-GRIDS.debug.offsetY+cellSize)/cellSize)
  -- local mCellX, mCellY = math.floor((mx-CIA.offsetX+cellSize)/cellSize), math.floor((my-CIA.offsetY+cellSize)/cellSize)
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)
  
  -- if gameMode == "map" then
  if cellExistsAt(mCellX, mCellY) then

    --is this somewhere that can be walked to?
    -- if GRIDS.debug[mCellY][mCellX].pathFromHero then
    if CIA[mCellY][mCellX].pathFromHero then  
      --TODO make this more readable
      -- local starty = findHeroLocationInGrid(GRIDS.debug)
      -- for i, step in ipairs(GRIDS.debug[mCellY][mCellX].pathFromHero) do
        local starty = findHeroLocationInGrid(CIA)
        for i, step in ipairs(CIA[mCellY][mCellX].pathFromHero) do			
        moveThingAtYX(starty.y, starty.x, step.y - starty.y, step.x - starty.x)

        starty = step
      end

      --debug. just clear obstacles and then add some
      -- queue(gridOpEvent(GRIDS.debug, "clear obstacles"))
      -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "block", threshold = 0.1}))
      -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "npc", threshold = 0.1}))
      -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "danger", threshold = 0.1}))
      -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "item", threshold = 0.1}))

      --then once done walking, remap the paths
      -- queue(gridOpEvent(GRIDS.debug, "remap"))
      queue(gridOpEvent(CIA, "remap"))
    end
  end
  -- else
  -- 	if grabbedThing and grabbedThing.item then
  -- 		if cellExistsAt(mCellX, mCellY) then
  -- 			queue(cellSwapEvent(GRIDS.debug, mCellY, mCellX, grabbedThing.originY, grabbedThing.originX))
  -- 		end
  --
  -- 		grabbedThing = nil
  -- 		processNow()
  -- 	end
  --
  -- 	-- grabbedThing = nil
  -- 	-- mouseDownAtX, mouseDownAtY = 0, 0 --i really feel like there should be a more efficient way to do this...
  -- 	mouseDownTimer = 0
  -- 	mouseStillDown = false
  -- 	mouseHasntMovedFar = false
  --
  -- 	processNow()
  -- end
end

function convertMouseCoordsToOverworldCoords(mx, my)
  local x = math.floor((mx-CIA.offsetX+cellSize*overworldZoom)/cellSize/overworldZoom)
  local y = math.floor((my-CIA.offsetY+cellSize*overworldZoom)/cellSize/overworldZoom)
  
  return x, y
end

function love.mousemoved(mx,my)
  -- local mCellX, mCellY = math.floor((mx-GRIDS.debug.offsetX+cellSize)/cellSize), math.floor((my-GRIDS.debug.offsetY+cellSize)/cellSize)
  -- local mCellX, mCellY = math.floor((mx-CIA.offsetX+cellSize)/cellSize), math.floor((my-CIA.offsetY+cellSize)/cellSize)
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)

  --are we now hovering over a grid cell?
  --note that this will not really be a thing when the game is for touchscreens...
  hoveredCell = nil

  -- for y=1, 3 do
  -- 	for x=1, 3 do
  -- for k, v in ipairs(allCellsInGrid(GRIDS.debug)) do
  for k, v in ipairs(allCellsInGrid(CIA)) do
    if v.y == mCellY and v.x == mCellX then
      -- GRIDS.debug[y][x].mouseOver = true
      v.cell.mouseOver = true
      hoveredCell = {y = mCellY, x = mCellX} --wait, why is this needed?
    else
      v.cell.mouseOver = false
    end
    -- end
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
  -- if my >= GRIDS.debug.offsetY and my <= cellSize * 5 + GRIDS.debug.offsetY and mx >= GRIDS.debug.offsetX and mx <= cellSize * 5 + GRIDS.debug.offsetX then
  --   local cx, cy = math.floor((mx-GRIDS.debug.offsetX+cellSize)/cellSize), math.floor((my-GRIDS.debug.offsetY+cellSize)/cellSize)
  --
  --   if GRIDS.debug[cy] and GRIDS.debug[cy][cx] and GRIDS.debug[cy][cx].contents then
  --     return GRIDS.debug[cy][cx].contents
  --   end
  -- end
  if my >= CIA.offsetY and my <= cellSize * 5 + CIA.offsetY and mx >= CIA.offsetX and mx <= cellSize * 5 + CIA.offsetX then		
    local cx, cy = math.floor((mx-CIA.offsetX+cellSize)/cellSize), math.floor((my-CIA.offsetY+cellSize)/cellSize)

    if CIA[cy] and CIA[cy][cx] and CIA[cy][cx].contents then
      return CIA[cy][cx].contents
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
      -- queue(cellSwapEvent(GRIDS.debug, math.random(3), math.random(3), math.random(3), math.random(3)))
      queue(cellSwapEvent(CIA, math.random(3), math.random(3), math.random(3), math.random(3)))
    end
  end

  if key == "d" then
    -- tablePrint(findHeroLocationInGrid(GRIDS.debug))
    tablePrint(findHeroLocationInGrid(CIA))
  end

  if key == "i" then
    -- tablePrint(GRIDS)
    tablePrint(island)
  end
end

--not sure if this is really that helpful...
function cellExistsAt(x, y)
  -- if GRIDS.debug[y] and GRIDS.debug[y][x] then
  if CIA[y] and CIA[y][x] then
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

--for use when you need to read all the cells in a 2D array and don't want to do the nested 'for' loops. kinda dumb, but worth a try.
--GOOD for tallying stat bonuses or checking for the presence of a single thing
--NOT good for geometric things like pathing, finding syncs, targeting actions, etc
--MIGHT work for times you need to change the contents/properties of all grid cells, but not sure. still avoid geometric contexts, of course.
function allCellsInGrid(g)
  local cells = {}

  for y, row in ipairs(g) do
    for x, cell in ipairs(row) do
      push(cells, {y = y, x = x, cell = cell})
    end
  end

  return cells
end