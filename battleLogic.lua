require "damageFormula"
require "battleCommand"

function initBattleSystem()
  BATTLE = {}
  
  BATTLE.canvas = love.graphics.newCanvas(cellSize * AREASIZE, cellSize * AREASIZE)
  BATTLE.canvas:setFilter("nearest")
  
  initBattleGrid()
  
  BATTLE.bgColor = {r = 0.125, g = 0.0625, b = 0.25}
  
  BATTLE.targetedCell = nil
  
  BATTLE.effectTexts = {}
  
  BATTLE.particleSystems = {}
  
  
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
  mainCommandsGrids[1][2][3] = {contents = "DISMISS", bgColor = {r = 0.4, g = 0.4, b = 0.2}, lineColor = white(0.5), command = "heroDismiss"}
  mainCommandsGrids[1][3][1] = {contents = "END TURN (debug)", bgColor = {r = 0.2, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroEndTurn"}
  mainCommandsGrids[1][3][3] = {contents = "RUN AWAY", bgColor = {r = 0.2, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroEscape"}
  
  --can i load a skill based on data? 
  --all very DEBUG obviously... skills will mainly go in separate mind grids, and faves will be managed another different way
  local skill = HERO.skills[1]
  mainCommandsGrids[1][3][2] = {contents = skill.name, bgColor = {r = 0.8, g = 0.2, b = 0.2}, lineColor = white(0.5), command = "heroUseSkill", commandParams = 1} 
  --DEBUG DEBUG DEBUG
  
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

function updateBattleLogic(dt)  
  updateBattleEffectText(dt)
  
  updateBattleParticleSystems(dt)
end

function updateBattleEffectText(dt)
  --for flying text, consider: position & movement, colors incl. changing/flashing/fading out, size variation, expiration/removing, lots displaying at once in different places
  for k, t in ipairs(BATTLE.effectTexts) do
    if t.timer > 2 then
      table.remove(BATTLE.effectTexts, k)
    else
      t.timer = t.timer + dt
      t.y = t.y - dt * 10
      t.color.a = 2 - t.timer
      --TODO these numbers should be constants
      --TODO make the text bigger? somehow?
    end    
  end
end

function updateBattleParticleSystems(dt)
  for k, ps in ipairs(BATTLE.particleSystems) do
    ps:update(dt)
  end
end

--player clicked/tapped during GAMESTATE == "battle". what now?
function battleClick(mx, my, button)
  local mCellX, mCellY = convertMouseCoordsToBattleGridCoords(mx, my)
  
  --TODO ain't nothing happening if it's not your turn... unless you want a click at that point to pause everything?
  
  --is this a battlefield cell?
  if 1 <= mCellX and mCellX <= 3 and 1 <= mCellY and mCellY <= 3 then --TODO abstract somehow
    setOrRemoveBattleTargetedCell(mCellX, mCellY) --TODO should only happen in a logic branch if 1. it's your turn and 2. (? lol, unfinished thought)
  end
  
  --is this a battle command grid cell?
  if 1 <= mCellX and mCellX <= 3 and 5 <= mCellY and mCellY <= 7 then --TODO abstract somehow
    mCellY = mCellY - 4
    --TODO mainCommandsGrids[mainCommandsGrids.current] is very clumsy. abstract. abstract all of this!
    -- tablePrint(mainCommandsGrids[mainCommandsGrids.current][mCellY][mCellX])
    
    local cell = mainCommandsGrids[mainCommandsGrids.current][mCellY][mCellX]
    if cell.command then
      battleCommand(cell.command, cell.commandParams)
    end
  end
  
  -- print(mCellX, mCellY)
  -- tablePrint(BATTLE.grid[mCellX][mCellY].pathFromHero)
  
  processNow()
end

--sets the target if it doesn't exist or needs to be moved; otherwise deletes it
function setOrRemoveBattleTargetedCell(mx, my)
  if BATTLE.targetedCell then
    if BATTLE.targetedCell.y == my and BATTLE.targetedCell.x == mx then --TODO *could* simplify this if higher caller is safe, but maybe leave as is
      BATTLE.targetedCell = nil
    else
      setBattleTargetedCell(mx, my)
    end
  else
    setBattleTargetedCell(mx, my)
  end
  
  -- tablePrint(BATTLE.targetedCell)
end

function setBattleTargetedCell(mx, my) --TODO ooh, you're bad. why is this x-y instead of y-x?
  if BATTLE.grid[my] and BATTLE.grid[my][mx] then
    BATTLE.targetedCell = {y = my, x = mx}
  end
end

function getBattleTargetedCell()
  return BATTLE.grid[BATTLE.targetedCell.y][BATTLE.targetedCell.x]
end

--TODO fix up, maybe combine with the overworld version?
function convertMouseCoordsToBattleGridCoords(mx, my)
  local x = math.floor(mx / cellSize / overworldZoom)
  local y = math.floor(my / cellSize / overworldZoom)
  
  return x, y
end


-----------------------------------------------------------------------------------------------------------

--TODO this is apparently necessary, but you should clarify that it's just a "proxy" for the hero
--...OR re-architect some stuff so that ALL grid units are proxies that point to external data? TODO this might be better
function battleUnit_hero()
  local en = {
    class = "hero",
    yOffset = 0,
    xOffset = 0,
    data = HERO --? or something
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
