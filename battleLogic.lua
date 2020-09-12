require "damageFormula"

function initBattleSystem()
  BATTLE = {}
  
  BATTLE.canvas = love.graphics.newCanvas(cellSize * AREASIZE, cellSize * AREASIZE)
  BATTLE.canvas:setFilter("nearest")
  
  initBattleGrid()
  
  BATTLE.bgColor = {r = 0.125, g = 0.0625, b = 0.25}
  
  BATTLE.targetedCell = nil
  
  
  --TODO this'll probably need to be made, saved, etc elsewhere
  --TODO remember that this is actually multiple grids! up to 3, i think
  --TODO? i still think "contents" is weird here if it's just going to be a string. why not call the attribute "command"?
  mainCommandsGrids = {}
  mainCommandsGrids[1] = new3x3Grid({contents = nil, bgColor = invisible(), lineColor = white(0.5)})
  mainCommandsGrids.current = 1
  mainCommandsGrids.offsetY, mainCommandsGrids.offsetX = cellSize * 5, cellSize
  
  --eventually all of this will need to be loaded from data since the command grids are configurable TODO
  mainCommandsGrids[1][1][1] = {contents = "ATTACK", bgColor = {r = 0.4, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroAttack"}
  mainCommandsGrids[1][1][2] = {contents = "MOVE", bgColor = {r = 0.2, g = 0.4, b = 0.2}, lineColor = white(0.5), command = "heroMove", commandParams = "DEBUG"}
  mainCommandsGrids[1][1][3] = {contents = "POTION", bgColor = {r = 0.2, g = 0.4, b = 0.4}, lineColor = white(0.5), command = "heroPotion"}
  mainCommandsGrids[1][3][1] = {contents = "END TURN (debug)", bgColor = {r = 0.2, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroEndTurn"}
  mainCommandsGrids[1][3][3] = {contents = "RUN AWAY", bgColor = {r = 0.2, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroEscape"}
  
  -- tablePrint(mainCommandsGrids)
  
  --graphical gradients. TODO maybe put these somewhere else? outside of draw() is good, though...
  blackGradientTop = gradientMesh("vertical", black(), invisible())
  blackGradientBottom = gradientMesh("vertical", invisible(), black())
end

function initBattleGrid()
  BATTLE.grid = new3x3Grid({
    contents = {class = "clear"},
    fieldEffect = nil,
    bgColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
    lineColor = {r = 0.75, g = 0.75, b = 0.75, a = 0.75},
    danger = 1,
  })
  
  BATTLE.grid.offsetY, BATTLE.grid.offsetX = cellSize, cellSize
end

-----------------------------------------------------------------------------------------------------------

--player clicked/tapped during GAMESTATE == "battle". what now?
function battleClick(mx, my, button)
  local mCellX, mCellY = convertMouseCoordsToBattleGridCoords(mx, my)
  
  --TODO ain't nothing happening if it's not your turn... unless you want a click at that point to pause everything?
  
  --is this a battlefield cell?
  if 1 <= mCellX and mCellX <= 3 and 1 <= mCellY and mCellY <= 3 then --TODO abstract somehow
    setOrRemoveBattleTargetCell(mCellX, mCellY) --TODO should only happen in a logic branch if 1. it's your turn and 2. (? lol, unfinished thought)
  end
  
  --is this a battle command grid cell?
  if 1 <= mCellX and mCellX <= 3 and 5 <= mCellY and mCellY <= 7 then --TODO abstract somehow
    mCellY = mCellY - 4
    --TODO mainCommandsGrids[mainCommandsGrids.current] is very clumsy. abstract. abstract all of this!
    -- tablePrint(mainCommandsGrids[mainCommandsGrids.current][mCellY][mCellX])
    
    -- local command = mainCommandsGrids[mainCommandsGrids.current][mCellY][mCellX].command
    local cell = mainCommandsGrids[mainCommandsGrids.current][mCellY][mCellX]
    if cell.command then
      -- _G[command]() --not like this!
      -- pcall(command)
      local bc = "battleCommand_"..cell.command
      local success, error = pcall(_G[bc], cell.commandParams)
      if error and not success then
        print("tried to run "..bc..", but this happened:\n"..error)
      end
    end
  end
  
  -- print(mCellX, mCellY)
  -- tablePrint(BATTLE.grid[mCellX][mCellY].pathFromHero)
end

--sets the target if it doesn't exist or needs to be moved; otherwise deletes it
function setOrRemoveBattleTargetCell(mx, my)
  if BATTLE.targetedCell then
    if BATTLE.targetedCell.y == my and BATTLE.targetedCell.x == mx then --TODO *could* simplify this if higher caller is safe, but maybe leave as is
      BATTLE.targetedCell = nil
    else
      setBattleTargetCell(mx, my)
    end
  else
    setBattleTargetCell(mx, my)
  end
  
  -- tablePrint(BATTLE.targetedCell)
end

function setBattleTargetCell(mx, my)
  if BATTLE.grid[my] and BATTLE.grid[my][mx] then
    BATTLE.targetedCell = {y = my, x = mx}
  end
end

--TODO rename these? "target" vs "targeted"... meh?
function getBattleTargetCell()
  return BATTLE.grid[BATTLE.targetedCell.y][BATTLE.targetedCell.x]
end

function convertMouseCoordsToBattleGridCoords(mx, my)
  local x = math.floor(mx / cellSize / overworldZoom)
  local y = math.floor(my / cellSize / overworldZoom)
  
  return x, y
end


-----------------------------------------------------------------------------------------------------------

function battleUnit_hero()
  local en = {
    class = "hero",
    yOffset = 0,
    xOffset = 0
  }
  
  en.color = {r = 1, g = math.random(), b = math.random()}
  
  -- en.stats = {
  --   maxHP = 999,
  --   hp = 999,
  --   ps = 9, --physical strength
  --   pr = 9, --physical resistance
  --   es = 9, --elemental strength
  --   er = 9, --elemental resistance ...these are subject to change, obvs
  --   level = 1,
  --   weight = 9,
  -- }
  
  return en
end

function battleUnit_enemy()
  local en = {class = "unit"}
  
  en.color = {r = 1, g = math.random(), b = math.random()}
  
  en.stats = {
    maxHP = 999,
    hp = 999,
    ps = 9, --physical strength
    pr = 9, --physical resistance
    es = 9, --elemental strength
    er = 9, --elemental resistance ...these are subject to change, obvs
    level = 1,
    weight = 9,
  }
  
  return en
end

-----------------------------------------------------------------------------------------------------------

-- because Love can be shut down at any time but we want to be able to resume in the middle of battle...
function saveBattleState()
  --save battlefield & unit data
  
  --save all events? 
  --...yikes. like every single frame? i don't think so :/
  
  --meta-TODO: architect this! 
  --probably call it only when Love loses focus or whatever
  --break into pieces: an auto-save for unit/battle data after every unit's turn (not that memory-intensive) + one for losing & regaining focus
  --this will require a LOT of testing
  --don't save particle data? heh. some things will have to be omitted, probably. maybe some silly, generic animation plays if you quit & resume mid-animation
  --also architect loading, not just saving. woof. i guess be ready to load the game to ANY state :/ but maybe show a "resume / title screen" page first?
  --overall: wow, what a pain. but it's necessary in this engine...
  --important consideration: prevent scumming by pre-determining action resolution, i.e. only call math.random() when you'll also save in that same frame
end


-----------------------------------------------------------------------------------------------------------

--TODO move this somewhere, probably a new file
function battleCommand_heroAttack()
  print("heroAttack time!")
  
  if not BATTLE.targetedCell then
    print("...no target, dummy")
    return
    --TODO obviously auto-target something
  end
  
  print("ping")
  
  --calculate damage
  local damage = damageFormula("attack", {user = HERO, target = getBattleTargetCell().contents, potency = 100})
  
  --queue events: damage, animation; hp actuation
  -- queueSet({
    queue(battleEvent(
      {user = HERO, target = getBattleTargetCell().contents, damage = damage}
    ))
  -- })
end

function battleCommand_heroMove(test)
  if test then
    -- tablePrint(test)
    print(test)
  end
  
  --TODO check for other things... what's actually in the targeted cell (it doesn't actually have to be "clear")? it's not where you already are, right? etc
  if BATTLE.targetedCell then
    local tCell = BATTLE.grid[BATTLE.targetedCell.y][BATTLE.targetedCell.x]
    local starty = findHeroLocationInGrid(BATTLE.grid)
    
    if tCell.pathFromHero[1] and tCell.contents.class == "clear" then --can we actually go there?
      queue(battleGridOpEvent("clear target"))
      
      for k, step in ipairs(tCell.pathFromHero) do
        print("step:", step.y, step.x)
        moveBattleUnitAtYX(starty.y, starty.x, step.y - starty.y, step.x - starty.x)
        --TODO decrement AP
        --TODO interact with field effects

        starty = step
      end
      
      --TODO actual sprite animations? including poses & directions
      --TODO turn hero back south ("towards camera") after walk is done
      
      queue(battleGridOpEvent("hero remap")) --it's really perplexing that WITHOUT this, movement doesn't complete. why would that be?? TODO should really figure this out... it hints at deeper problem
      
      processNow()
    end
  end
end

--TODO this was *copied* from overworldLogic; DRY it up!
function moveBattleUnitAtYX(y, x, dy, dx, max)
  local ty, tx = y + dy, x + dx --t as in "target"

  --max = the number of movement frames it'll take this movement to finish
  max = max or maxFramesForHeroMove

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
      cellSwapEvent(BATTLE.grid, y, x, ty, tx), --eventually swapping won't work, but ok for now. DEBUG
      spriteMoveEvent(BATTLE.grid, ty, tx, moveFrames)
    })

  -- processNow()
end


--[[
  this is actually a pretty good flow for battle logic, i think...
1. register click, and find command in grid if present
2. battleClick() calls command as a function (no args); for MAIN COMMANDS, this is totally fine & makes sense
3. that function does all damage & effect calculation, then queues up events; NO STATE CHANGE THAT'S NOT EVENT-BASED
4. events simply resolve effects and animate
...this should work for pretty much any main command

for skills and grid switches, command should be "skill" or "grid", with a sub-parameter
battleClick actually just always passes the commandParams, which is a table containing skill or grid data

]]