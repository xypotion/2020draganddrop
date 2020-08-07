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
  
  BATTLE.bgColor = {r = 0.2, g = 0.1, b = 0.4}
end