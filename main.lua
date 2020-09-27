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
  1. very basic screen transition from overworld (use debug key) + show hero stats, enemy life bars?
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
- make a whole system of oscillators, so you can reference like OSC.soft.i, OSC.tiny.i. each is a table with its own tracked period, amplitude, starting pos

BUGS... FIXME
- hovered tile stays hovered after you leave area, and it still looks that way when you return
- why do all grass tiles in every area look the same? that seems wrong. same for the border blocks. huh.
]]


require "constants"
require "pathfinding"
require "hero"
require "helpers"
require "island"
require "battleLogic"
require "overworldLogic"
require "gear" --TODO move this and other requires, i think

require "data/dataManager"

require "draw/draw"

require "events/eventSetQueue"

-----------------------------------------------------------------------------------------------------------

function love.load()
  math.randomseed(os.time())

  love.window.setTitle("<3")

  love.window.setMode(cellSize * overworldZoom * AREASIZE, cellSize * overworldZoom * (AREASIZE * 2 - 1))

  initEventQueueSystem()


  --DEBUG never tried image fonts before...
  imgFont = love.graphics.newImageFont("love-wiki-imagefont.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")--, -1) TODO consider this kind of thing!
  love.graphics.setFont(imgFont, 200)
  imgFont:setFilter("linear", "nearest")
  -- imgFont:setLineHeight(1.25)
  -- love.graphics.scale(20) --seemingly does nothing unless called while drawing
  
  -- hoveredCell = nil
  -- grabbedThing = nil
  -- mouseDownTimer = 0
  -- mouseDownAtX, mouseDownAtY = 0, 0 --not sure if necessary
  -- mouseStillDown = false
  -- mouseHasntMovedFar = false


  softOscillator = 1
  oscillatorCounter = 0
  
  love.graphics.setLineWidth(2)
  
  loadGraphics()

  initHERO()
  
  initOverworldSystem()
  
  initBattleSystem()
  
  GAMESTATE = "overworld"
    
  -- a, b, c, d, e = pcall(function() return 1, 2, 3, 4, 5 end)
  -- print(a, b, c, d, e)
end

-----------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------

function love.update(dt)
  oscillatorCounter = oscillatorCounter + dt * 5 % TAU
  softOscillator = 0.25 + math.sin(oscillatorCounter) * 0.0625

  eventProcessing(dt)

  --just commented out for now, but TODO probably recycle some of this when you get to real drag-and-drop interfaces
  --still maybe doing a long press?
  -- if mouseHasntMovedFar and grabbedThing then
  --   local dx, dy = love.mouse.getX() - mouseDownAtX, love.mouse.getY() - mouseDownAtY
  --
  --   if dx * dx + dy * dy > 100 then
  --     mouseHasntMovedFar = false
  --     mouseDownTimer = 0
  --   end
  -- end
  --
  -- --yes, so far still doing a long press
  -- --TODO this block can almost definitely be consolidated with the above one
  -- if mouseHasntMovedFar then
  --   --keep counting the long-press timer up
  --   if love.mouse.isDown(1) then
  --     mouseDownTimer = mouseDownTimer + dt
  --   end
  --
  --   --done counting! do that long press
  --   --also reset stuff so we don't repeatedly do long-press stuff
  --   if mouseDownTimer >= longPressTime and not mouseStillDown then
  --     longPressEventAt(love.mouse.getPosition())
  --
  --     mouseDownTimer = 0
  --     mouseStillDown = false
  --     mouseHasntMovedFar = false
  --     grabbedThing = nil
  --   end
  -- end
  
  if GAMESTATE == "battle" then
    updateBattleLogic(dt)
  end
end

-----------------------------------------------------------------------------------------------------------

function love.mousepressed(mx, my, button)
  --TODO make this more like mousereleased :)
  
  -- local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)
  --
  -- mouseDownAtX, mouseDownAtY = mx, my
  -- 
  -- if we're clicking in the grid and there's an item there, "grab" it... TODO this sucks. clean it up
  -- if CIA[mCellY] and CIA[mCellY][mCellX] and CIA[mCellY][mCellX].contents and CIA[mCellY][mCellX].contents.class ~= "clear" then
  --   grabbedThing = {
  --     -- item = GRIDS.debug[mCellY][mCellX].contents,
  --     item = CIA[mCellY][mCellX].contents,
  --     -- relMouseY = my - cellSize * (mCellY - 1) - GRIDS.debug.offsetY, --to prevent the graphic from jumping to a weird place near the cursor when grabbed
  --     -- relMouseX = mx - cellSize * (mCellX - 1) - GRIDS.debug.offsetX,
  --     relMouseY = my - cellSize * (mCellY - 1) - CIA.offsetY, --to prevent the graphic from jumping to a weird place near the cursor when grabbed
  --     relMouseX = mx - cellSize * (mCellX - 1) - CIA.offsetX,
  --     originY = mCellY,
  --     originX = mCellX
  --   }
  --
  --  mouseHasntMovedFar = true
  -- end
end

-----------------------------------------------------------------------------------------------------------

--TODO prevent input from doing anything when an animation (event) is in progress!
function love.mousereleased(mx, my, button)
  if GAMESTATE == "overworld" then
    overworldClick(mx, my, button)
  elseif GAMESTATE == "battle" then 
    battleClick(mx, my, button)
  end
end

-----------------------------------------------------------------------------------------------------------

function love.mousemoved(mx,my)
  --TODO maybe make this more like mousereleased... but it's kind of all DEBUG for now. 
  --touchscreens won't need this except when dragging and dropping stuff
  
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)

  --are we now hovering over a grid cell?
  --note that this will not really be a thing when the game is for touchscreens...
  hoveredCell = nil

  for k, v in ipairs(allCellsInGrid(CIA)) do
    if v.y == mCellY and v.x == mCellX then
      v.cell.mouseOver = true
      
      hoveredCell = {y = mCellY, x = mCellX} --this informs the path-drawing code
    else
      v.cell.mouseOver = false
    end
  end
end

-----------------------------------------------------------------------------------------------------------

--TODO https://love2d.org/wiki/love.lowmemory and other callbacks... probably think about implementing! :)

--https://love2d.org/wiki/love.displayrotated is interesting....

-----------------------------------------------------------------------------------------------------------

function longPressEventAt(mx, my)
  local t = getTopThingAtPos(mx, my)

  print(t.message)

  local r, g, b = math.random(), math.random(), math.random()
  t.color = {r, g, b, 1}
  t.fadeColor = {r, g, b, 0.5}
  t.message = "my darkness is this strong: "..(1/(r+g+b))
end

--TODO maybe change this to just take cell coords and a grid/context
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

-----------------------------------------------------------------------------------------------------------

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
  
  if key == "b" then 
    local heroLoc = findHeroLocationInGrid(CIA)
    
    if heroLoc.y == 1 or heroLoc.y == 5 or heroLoc.x == 1 or heroLoc.x == 5 then
      print("lol, no")
      return
    end
    
    -- tablePrint(BATTLE, 2)
    
    --this will be overlaid on the existing BATTLE.grid. hero is "placed" at this point
    local battleGrid = {
      {y = math.random(3), x = math.random(3), contents = loadEnemy("ditto")},--battleUnit_enemy("ditto")},
      {y = math.random(3), x = math.random(3), contents = loadEnemy("ditto")},--battleUnit_enemy("ditto")},
      {y = heroLoc.y - 1, x = heroLoc.x - 1, contents = battleUnit_hero()}--{class = "hero"}} --TODO battleUnit_hero()?
    }
    
    queueSet({gameStateEvent("battle"), 
      battleStartEvent({gridContents = battleGrid})
    })  
    --kinda DEBUG, just since there's no guarantee you'll get the first turn. but for now...
    queue(battleGridOpEvent("hero remap"))
  end
  
  if key == "h" then
    tablePrint(findHeroLocationInGrid(BATTLE.grid))
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