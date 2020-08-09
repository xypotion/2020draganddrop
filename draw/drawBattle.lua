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
  
  white()
  love.graphics.draw(BATTLE.canvas, 0, 0, 0, overworldZoom, overworldZoom)
  
  drawBattleDebugInfo()
end

function drawBattleGrid()
  drawBattleCellBackgrounds()
  
  drawBattleCellContents()
  
  drawBattleCellOverlays()
  
  if BATTLE.targetedCell then -- AND it's your turn & there's no animation playing TODO
    white()
    local targetY = (BATTLE.targetedCell.y + 0.5) * cellSize
    local targetX = (BATTLE.targetedCell.x + 0.5) * cellSize
    -- love.graphics.arc("line", "open", targetX, targetY, cellSize/2, (softOscillator * 8 + 0.0) * TAU, (softOscillator * 8 + 0.25) * TAU)
    -- love.graphics.arc("line", "open", targetX, targetY, cellSize/2, (softOscillator * 8 + 0.5) * TAU, (softOscillator * 8 + 0.75) * TAU)
    love.graphics.arc("line", "open", targetX, targetY, cellSize/2, (oscillatorCounter * 0.25 + 0.0) * TAU, (oscillatorCounter * 0.25 + 0.125) * TAU)
    love.graphics.arc("line", "open", targetX, targetY, cellSize/2, (oscillatorCounter * 0.25 + 0.5) * TAU, (oscillatorCounter * 0.25 + 0.625) * TAU)
  end
  
  --drawBattleAnimations() --tough one. so many possibilities here.
  
  --drawBattleNumbers() --ditto
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
  for k, v in ipairs(allCellsInGrid(BATTLE.grid)) do
    if v.cell.contents.class == "unit" then --or whatever. TODO. could also make this logic safer
      white()
      love.graphics.rectangle("fill", (v.x-1) * cellSize + BATTLE.grid.offsetX, (v.y-1) * cellSize + BATTLE.grid.offsetY, 10, 10)
    end
  end
end

function drawBattleCellOverlays()
  --was going to put targeted cell here, but that's not appropriate
  --i guess particles and other effects could go here? if necessary?
end


function drawBattleDebugInfo()
  local debugInfo = "hero stats:\n"
  debugInfo = debugInfo..HERO.baseStats.maxHP.."\n"
  
  white()
  love.graphics.print(debugInfo, 10, cellSize * overworldZoom * 5 + 10)
end