function initBattleSystem()
  BATTLE = {}
  
  BATTLE.canvas = love.graphics.newCanvas(cellSize * AREASIZE, cellSize * AREASIZE)
  BATTLE.canvas:setFilter("nearest")
  
  initBattleGrid()
  
  BATTLE.bgColor = {r = 0.1, g = 0.05, b = 0.2}
  
  BATTLE.targetedCell = nil
  
  
  --TODO this'll probably need to be made, saved, etc elsewhere
  --TODO remember that this is actually multiple grids! up to 3, i think
  --TODO? i still think "contents" is weird here if it's just going to be a string. why not call the attribute "command"?
  mainCommandsGrids = {}
  mainCommandsGrids[1] = new3x3Grid({contents = nil, bgColor = invisible(), lineColor = white(0.5)})
  mainCommandsGrids.current = 1
  mainCommandsGrids.offsetY, mainCommandsGrids.offsetX = cellSize * 5, cellSize
  
  mainCommandsGrids[1][1][1] = {contents = "ATTACK", bgColor = {r = 0.4, g = 0.2, b = 0.2}, lineColor = white(0.5)}
  mainCommandsGrids[1][1][2] = {contents = "MOVE", bgColor = {r = 0.2, g = 0.4, b = 0.2}, lineColor = white(0.5)}
  mainCommandsGrids[1][3][3] = {contents = "RUN AWAY", bgColor = {r = 0.2, g = 0.2, b = 0.2}, lineColor = white(0.5)}
  
  -- tablePrint(mainCommandsGrids)
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

function battleClick(mx, my, button)
  local mCellX, mCellY = convertMouseCoordsToBattleGridCoords(mx, my)
  
  setOrRemoveBattleTargetCell(mCellX, mCellY)
end

function setOrRemoveBattleTargetCell(mx, my)
  if BATTLE.targetedCell then
    if BATTLE.targetedCell.y == my and BATTLE.targetedCell.x == mx then
      BATTLE.targetedCell = nil
    else
      setBattleTargetCell(mx, my)
    end
  else
    setBattleTargetCell(mx, my)
  end
  
  tablePrint(BATTLE.targetedCell)
end

function setBattleTargetCell(mx, my)
  if BATTLE.grid[my] and BATTLE.grid[my][mx] then
    BATTLE.targetedCell = {y = my, x = mx}
  end
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
  
  return en
end