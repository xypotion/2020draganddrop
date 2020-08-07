function drawBattle()
  love.graphics.setCanvas(BATTLE.canvas) 
  love.graphics.clear(0,0,0,1)
  -- love.graphics.clear(BATTLE.bgColor)
  
  -- tablePrint(BATTLE.bgColor)
  
  setColor(BATTLE.bgColor)
  -- white()
  love.graphics.rectangle("fill", 0, 0, cellSize * AREASIZE, cellSize * AREASIZE)
  
  drawBattleGrid()
  
  love.graphics.setCanvas()
  love.graphics.draw(BATTLE.canvas, 0, 0, 0, overworldZoom, overworldZoom)
end

function drawBattleGrid()
  drawBattleCellBackgrounds()
  
  drawBattleCellContents()
end

function drawBattleCellBackgrounds()
  for k, v in ipairs(allCellsInGrid(BATTLE.grid)) do
    -- if v.cell.mouseOver then --honestly this entire block is DEBUG. won't matter on a touchscreen
    --   setColor(v.cell.bgHoverColor)
    -- else
      setColor(v.cell.bgColor)
    -- end
    -- white()

    love.graphics.rectangle("fill", (v.x-1) * cellSize + BATTLE.grid.offsetX, (v.y-1) * cellSize + BATTLE.grid.offsetY, cellSize, cellSize)
    
    setColor(v.cell.lineColor)
    love.graphics.rectangle("line", (v.x-1) * cellSize + BATTLE.grid.offsetX, (v.y-1) * cellSize + BATTLE.grid.offsetY, cellSize, cellSize)
  end
end

function drawBattleCellContents()
end