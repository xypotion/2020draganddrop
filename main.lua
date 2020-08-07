--[[
sort of hilarious that this doesn't do dragging and dropping anymore, and it never related to matching :P

TODO features
- UX for non-overworld grids; nav on top, drag & drop on bottom
  - "inventory" or "drawer" of items to drag into/between grids. maybe can drag obstacles from bottom to top? :)
  - uh, and a million other non-overworld, non-battle things
- obs-tacular pathing, like different ways of pathing near/around/over different types of things to avoid danger if possible. 
  - maybe just add "danger" rating to all cells, then use that to make decisions in the pathfinding algo; enemies have dangerous zones around them
  - alternative, maybe easier: can you map to a cell without passing by an enemy, i.e. enemy-adjacent cells = "blocked"? if so, do that. if not, then path normally
  - if possible, maybe also make it so hero always walks through the middle of an area if it's clear & safe, just to prevent unnecessary zig-zagging
- color-coded map dots/something to indicate what all happens when you tap them
- actual island-building rules :)
- minimap; show only visited areas
- battle system!
  1. very basic screen transition from overworld (use debug key) + show hero stats, enemy life bars
  2. show basic command grid, then allow UI switching
  3. implement BattleEffect and make things happen when you do battle actions; somewhere here make all info/stats update whenever something happens (use actuators!)
  4. long-press on stuff to see info
  5. implement AP & turns, then basic enemy AI
  6. more complicated battle effects, and start battle animations (particle effects and/or frame-based animations)
  7. other stuff... grid-switching, battle start + end transitions, pets/summons, ally AI, potions, multipage command grid & customization, ...

TODO random things
- idea: make a "luaMod" or "highMod" or even %% operator that shifts the modulo window up by 1, so we don't have to fuck around with off-by-1 mod ops
- build & test this shit on android
  - ugh, and start building a quicksave framework with auto-serialize or recursive table-zipping... but also check forums to see if there's a better way. :/

BUGS... FIXME
- hovered tile stays hovered after you leave area, and it still looks that way when you return
- why do all grass tiles in every area look the same? that seems wrong. same for the border blocks. huh.
]]


require "pathfinding"
require "hero"
require "helpers"
require "island"
require "battleLogic"

require "draw/draw"

require "events/eventSetQueue"

function love.load()
  math.randomseed(os.time())

  love.window.setTitle("<3")

  cellSize, overworldZoom = 72, 1

  ISLANDSIZE = 3
  AREASIZE = 5

  overworldCanvas = love.graphics.newCanvas(cellSize * AREASIZE, cellSize * AREASIZE)
  overworldCanvas:setFilter("nearest")

  love.window.setMode(cellSize * overworldZoom * AREASIZE, cellSize * overworldZoom * (AREASIZE * 2 - 1))

  initEventQueueSystem()

  --this is not elegant (you're mapping twice at boot), but it's debug junk anyway. doesn't matter
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "block", threshold = 0.1}))
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "npc", threshold = 0.1}))
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "danger", threshold = 0.1}))
  -- queue(gridOpEvent(GRIDS.debug, "add obstacles", {type = "item", threshold = 0.1})) --TODO document these in gridOps before deleting. lol
  -- queue(gridOpEvent(GRIDS.debug, "remap"))

  --init island and CIA "current island area"
  currentIsland = initIsland()
  CIA = currentIsland[currentIsland.areaNumbersReference[1].y][currentIsland.areaNumbersReference[1].x]

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

  CIA = mapAllPathsFromHero(CIA) --TODO might rather make this just "mapAllPathsFrom", then provide coordinates. also maybe a mode?

--  grabbedThing = nil

  longPressTime = 0.5
  mouseDownTimer = 0
  mouseDownAtX, mouseDownAtY = 0, 0 --not sure if necessary
  mouseStillDown = false
  mouseHasntMovedFar = false

  --also TODO shouldn't there be a way to not make this return things
  gameMode = "debug" --TODO shouldn't be necessary! remove & simplify
  hoveredCell = nil

  softOscillator = 1
  oscillatorCounter = 0
  TAU = math.pi * 2

  --pretending i know how the hero object will be structured
  initHERO()
  -- tablePrint(HERO)
  
  initBattleSystem()
  
  GAMESTATE = "overworld"
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



-----------------------------------------------------------------------------------------------------------


--called for queueing move events after input is given
function moveThingAtYX(y, x, dy, dx, max)
  local ty, tx = y + dy, x + dx --t as in "target"

  --max = the number of movement frames it'll take this movement to finish
  max = max or 6

  local moveFrames = {}

  for k = max - 1, 0, -1 do
    push(moveFrames, {
        pose = "idle", 
        yOffset = dy * -(cellSize * k / max), 
        xOffset = dx * -(cellSize * k / max)
      })
  end

  --queue pose and cell ops
  queueSet({
      cellSwapEvent(CIA, y, x, ty, tx), --eventually swapping won't work, but ok for now. DEBUG
      spriteMoveEvent(CIA, ty, tx, moveFrames)
    })

  processNow()
end

--similar to above...
--queue an areaMove event after building up its moveFrames
-- function moveAreaByDYDX(area, dy, dx, max)
--   max = max or 10 --the number of frames this movement should last
--
--   -- local moveFrames... wait. why am i doing this here, again?
-- end


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

--dy and dx describe the way the hero is moving... we're moving to a neighboring map, but which way?
function queueNextAreaMoveAndRemapEvents(dy, dx, heroY, heroX)
  local ciaCoords = currentIsland.areaNumbersReference[CIA.areaNumber]
  local nextArea = currentIsland[(ciaCoords.y + dy - 1) % ISLANDSIZE + 1][(ciaCoords.x + dx - 1) % ISLANDSIZE + 1]
  
  queueSet({
      primeAreaMoveEvent(dy, dx, nextArea),
      areaMoveEvent(nextArea, dy, dx), --by the time this processes, nextArea will be CIA (because of the primer)
      areaMoveEvent(CIA, dy, dx), --by the time this processes, CIA will be PIA
      areaTransferEvent(CIA, heroY, heroX, nextArea, (heroY + dy - 1) % AREASIZE + 1, (heroX + dx - 1) % AREASIZE + 1),
      --TODO still need a hero animation event! should be easy, though
    })
  queue(gridOpEvent(nextArea, "remap"))
end


--TODO prevent input from doing anything when an animation (event) is in progress!
function love.mousereleased(mx, my, button)
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)

--[[
  this is complicated... what are we doing?
  1. you've clicked a blocked tile -> nothing happens.
  2. you've clicked an open tile in the interior; it's open and has a pathFromHero -> build a path & queue up movement, then remap that area
  3. you've clicked an open tile on a boundary -> do above, except also queue up areaMoveEvent stuff, then remap for the NEXT area
  4. you've clicked on the hero not on a boundary -> nothing happens
  5. you've clicked on the hero ON a boundary -> send them back across that boundary to the neighboring area
  so logic... first check cell contents' class
    if blocked then do nothing
    if hero then 
      if on boundary
        area move, remap in new area
      else do nothing
    if clear then
      map there
      if boundary and not starting at boundary then
        area move
        remap in new area
      else
        remap in current area
      end
    end
  
  eh. try this?
  ]]  

  local cell = cellAt(mCellY, mCellX) 
  
  if cell then          
    --ok, what kind of cell is this?
    if cell.contents.class == "blocked" then
      --no-op :)
      
    elseif cell.contents.class == "hero" then
      --usually do nothing, unless we're on a border, in which case cross it again
      local dy, dx = 0, 0

      if mCellY == 1 then
        dy = -1
      elseif mCellY == 5 then
        dy = 1
      elseif mCellX == 1 then
        dx = -1
      elseif mCellX == 5 then
        dx = 1
      end
      
      queueNextAreaMoveAndRemapEvents(dy, dx, mCellY, mCellX)
      
    elseif cell.contents.class == "clear" and cell.pathFromHero[1] then
      local starty = findHeroLocationInGrid(CIA)
      
      --queue up move/swap events from step to step along path
      for i, step in ipairs(CIA[mCellY][mCellX].pathFromHero) do      
        moveThingAtYX(starty.y, starty.x, step.y - starty.y, step.x - starty.x)

        starty = step
      end
      
      --now check for area move & do that if needed, then remap one way or the other
      local endy = findHeroLocationInGrid(CIA)
      local dy, dx = 0, 0

      --are we going to a border cell from a not-border cell?
      if mCellY == 1 and endy.y ~= 1 then
        dy = -1
      elseif mCellY == 5 and endy.y ~= 5 then
        dy = 1
      elseif mCellX == 1 and endy.x ~= 1 then
        dx = -1
      elseif mCellX == 5 and endy.x ~= 5 then
        dx = 1
      end
      
      if (dy ~= 0 or dx ~= 0) then
        queueNextAreaMoveAndRemapEvents(dy, dx, mCellY, mCellX)
      else
        queue(gridOpEvent(CIA, "remap"))
      end
    end
  end
end

-- else
-- 	if grabbedThing and grabbedThing.item then
-- 		if cellAt(mCellX, mCellY) then
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

function convertMouseCoordsToOverworldCoords(mx, my)
  local x = math.floor((mx-CIA.offsetX+cellSize*overworldZoom)/cellSize/overworldZoom)
  local y = math.floor((my-CIA.offsetY+cellSize*overworldZoom)/cellSize/overworldZoom)

  return x, y
end

function love.mousemoved(mx,my)
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)

  --are we now hovering over a grid cell?
  --note that this will not really be a thing when the game is for touchscreens...
  hoveredCell = nil

  for k, v in ipairs(allCellsInGrid(CIA)) do
    if v.y == mCellY and v.x == mCellX then
      v.cell.mouseOver = true
      hoveredCell = {y = mCellY, x = mCellX} --wait, why is this needed? TODO
    else
      v.cell.mouseOver = false
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
      queue(cellSwapEvent(CIA, math.random(3), math.random(3), math.random(3), math.random(3)))
    end
  end

  if key == "d" then
    tablePrint(findHeroLocationInGrid(CIA))
  end

  if key == "i" then
    tablePrint(island)
  end

  -- if key == "e" then --move screen east
  --   queue(areaMoveEvent(currentIsland.areaNumbersReference[CIA.areaNumber], currentIsland, "east"))
  --   tablePrint(eventSetQueue)
  --   processNow()
  -- end
  
  if key == "b" then 
    queue(gameStateEvent("battle"))
  end
end

--gives you CIA[y][x] if it exists, otherwise nil
--TODO consider renaming to CIACellAt and/or making alternate versions
function cellAt(y, x)
  if CIA[y] then
    return CIA[y][x]
  else
    return nil
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