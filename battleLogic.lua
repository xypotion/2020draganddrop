function initBattleSystem()
  BATTLE = {}
  
  BATTLE.canvas = love.graphics.newCanvas(cellSize * AREASIZE, cellSize * AREASIZE)
  BATTLE.canvas:setFilter("nearest")
  
  
  BATTLE.grid = new3x3Grid({
    contents = "clear",
    bgColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
    lineColor = {r = 0.75, g = 0.75, b = 0.75, a = 0.75},
  })
  
  BATTLE.grid.offsetY, BATTLE.grid.offsetX = cellSize, cellSize
  
  BATTLE.bgColor = {r = 0.1, g = 0.05, b = 0.2}
  
  BATTLE.targetedCell = nil
end

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