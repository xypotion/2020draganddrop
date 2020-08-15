function drawBattle()
  drawBattlefield()
  
  drawBattleCommands()
end

-----------------------------------------------------------------------------------------------------------

function drawBattlefield()
  love.graphics.setCanvas(BATTLE.canvas) 
  love.graphics.clear(0,0,0,1)
  -- love.graphics.clear(BATTLE.bgColor)
  
  -- tablePrint(BATTLE.bgColor)
  
  setColor(BATTLE.bgColor)
  -- white()
  love.graphics.rectangle("fill", 0, 0, cellSize * AREASIZE, cellSize * AREASIZE)
      
  --top/bottom gradients. classy!
  white()
  love.graphics.draw(blackGradientTop, 0, 0, 0, cellSize * 5, cellSize)
  love.graphics.draw(blackGradientBottom, 0, cellSize * 4, 0, cellSize * 5, cellSize)
  
  drawBattlefieldGrid()
  
  love.graphics.setCanvas()
  
  white()
  love.graphics.draw(BATTLE.canvas, 0, 0, 0, overworldZoom, overworldZoom)
  
  drawBattleDebugInfo() --DEBUG, obviously
end

function drawBattlefieldGrid()
  drawBattleCellBackgrounds()
  
  drawBattleCellContents()
  
  drawBattleCellOverlays()
  
  --draw targeting ring if a cell is targeted
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
      setColor(v.cell.contents.color) --DEBUG
      love.graphics.rectangle("fill", (v.x-1) * cellSize + BATTLE.grid.offsetX + 10, (v.y-1) * cellSize + BATTLE.grid.offsetY + 10, 10, 10)
    elseif v.cell.contents.class == "hero" then
      white()
      love.graphics.rectangle("fill", (v.x-1) * cellSize + BATTLE.grid.offsetX + 10, (v.y-1) * cellSize + BATTLE.grid.offsetY + 10, 25, 25)
    end
  end
end

function drawBattleCellOverlays()
  --was going to put targeted cell here, but that's not appropriate
  --i guess particles and other effects could go here? if necessary?
end

-----------------------------------------------------------------------------------------------------------

function drawBattleCommands() --i want a better name for this :'(
  drawBattleMainCommands()
end

function drawBattleMainCommands()
  for k, v in pairs(allCellsInGrid(mainCommandsGrids[mainCommandsGrids.current])) do
    -- local offset = cellSize + mainCommandsGrids.offsetX
    
    setColor(v.cell.bgColor)
    -- setColor(1, 1, 0, 0.5)
    -- setColor({r=1, g=1, b=0, a=0.95})
    love.graphics.rectangle("fill", (v.x-1) * cellSize + mainCommandsGrids.offsetX, (v.y-1) * cellSize + mainCommandsGrids.offsetY, cellSize, cellSize)
    setColor(v.cell.lineColor)
    love.graphics.rectangle("line", (v.x-1) * cellSize + mainCommandsGrids.offsetX, (v.y-1) * cellSize + mainCommandsGrids.offsetY, cellSize, cellSize)
    
    --these draw/print commands are so ugly, not to mention repetetive... find some way to abstract them or make them cleaner! TODO DRY it up
    
    if v.cell.contents then
      white()
      love.graphics.printf(v.cell.contents, (v.x-1) * cellSize + mainCommandsGrids.offsetX, (v.y-1) * cellSize + mainCommandsGrids.offsetY, cellSize, "center")
    end
      
  end
end

-----------------------------------------------------------------------------------------------------------

function drawBattleDebugInfo()
  local debugInfo = "hero stats:\n"
  debugInfo = debugInfo..HERO.baseStats.maxHP.."\n"
  
  white()
  love.graphics.print(debugInfo, 10, cellSize * overworldZoom * 5 + 10)
end

-----------------------------------------------------------------------------------------------------------