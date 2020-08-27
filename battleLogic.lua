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
  
  mainCommandsGrids[1][1][1] = {contents = "ATTACK", bgColor = {r = 0.4, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroAttack"}
  mainCommandsGrids[1][1][2] = {contents = "MOVE", bgColor = {r = 0.2, g = 0.4, b = 0.2}, lineColor = white(0.5)}
  mainCommandsGrids[1][3][3] = {contents = "RUN AWAY", bgColor = {r = 0.2, g = 0.2, b = 0.2}, lineColor = white(0.5)}
  
  -- tablePrint(mainCommandsGrids)
  
  --graphical gradients. TODO maybe put these somewhere else? outside of draw() is good, though...
  blackGradientTop = gradientMesh("vertical", black(), invisible())
  blackGradientBottom = gradientMesh("vertical", invisible(), black())
end

function initBattleGrid()
  BATTLE.grid = new3x3Grid({
    contents = "clear",
    fieldEffect = nil,
    bgColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
    lineColor = {r = 0.75, g = 0.75, b = 0.75, a = 0.75},
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
    local command = mainCommandsGrids[mainCommandsGrids.current][mCellY][mCellX].command
    if command then
      -- _G[command]() --not like this!
      -- pcall(command)
      pcall(_G[command])
    end
  end
  
  print(mCellX, mCellY)
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

--TODO move this somewhere
function heroAttack()
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