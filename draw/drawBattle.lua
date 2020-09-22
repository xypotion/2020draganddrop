function drawBattle()
  drawBattlefield()
  
  drawBattleCommands()
  
  --draw info for targeted enemy/cell
  
  --draw other buttons and stuff in top canvas?
end

-----------------------------------------------------------------------------------------------------------

function drawBattlefield()
  love.graphics.setCanvas(BATTLE.canvas) 
  love.graphics.clear(0,0,0,1)
  -- love.graphics.clear(BATTLE.bgColor)
  
  -- tablePrint(BATTLE.bgColor)
  
  setColor(BATTLE.bgColor)
  love.graphics.rectangle("fill", 0, 0, cellSize * AREASIZE, cellSize * AREASIZE)
      
  --top/bottom gradients. classy!
  white()
  love.graphics.draw(blackGradientTop, 0, 0, 0, cellSize * 5, cellSize)
  love.graphics.draw(blackGradientBottom, 0, cellSize * 4, 0, cellSize * 5, cellSize)
  
  drawBattlefieldGrid()
  
  love.graphics.setCanvas()
  
  white()
  love.graphics.draw(BATTLE.canvas, 0, 0, 0, overworldZoom, overworldZoom)
  
  drawBattleParticleSystems()
  
  drawBattleEffectText()
  
  drawBattleDebugInfo() --DEBUG, obviously
end

function drawBattlefieldGrid()
  drawBattleCellBackgrounds()
  
  drawBattleCellContents()
  
  drawBattleCellOverlays()
  
  --draw targeting ring if a cell is targeted
  if BATTLE.targetedCell then -- AND it's your turn AND there's no animation playing TODO
    white()
    local targetY = (BATTLE.targetedCell.y + 0.5) * cellSize
    local targetX = (BATTLE.targetedCell.x + 0.5) * cellSize
    love.graphics.arc("line", "open", targetX, targetY, cellSize/2, (oscillatorCounter * 0.25 + 0.0) * TAU, (oscillatorCounter * 0.25 + 0.125) * TAU) --TODO make this a little less hacky, like make other counters
    love.graphics.arc("line", "open", targetX, targetY, cellSize/2, (oscillatorCounter * 0.25 + 0.5) * TAU, (oscillatorCounter * 0.25 + 0.625) * TAU)
    
    --draw hero's path to that cell
    for i, step in ipairs(BATTLE.grid[BATTLE.targetedCell.y][BATTLE.targetedCell.x].pathFromHero) do
      love.graphics.circle("line", (step.x-0.5)*cellSize + BATTLE.grid.offsetX, (step.y-0.5)*cellSize + BATTLE.grid.offsetY, cellSize*0.05)
    end
  end
  
  --drawBattleAnimations() --tough one. so many possibilities here.
  
  --drawBattleNumbers() --ditto
end

function drawBattleEffectText()
  for k, t in ipairs(BATTLE.effectTexts) do
    setColor(t.color)
    love.graphics.printf(t.text, t.x - cellSize * 0.5, t.y, cellSize * 1, "center", 0, 2, 2) --TODO establish constants or game settings
  end
end

function drawBattleParticleSystems()
  for i, ps in ipairs(BATTLE.particleSystems) do
    love.graphics.draw(ps, 0, 0)
  end
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
  white()
  for k, v in ipairs(allCellsInGrid(BATTLE.grid)) do
    if v.cell.contents.class == "enemy" then --or whatever. TODO. could also make this logic safer
      local unit = v.cell.contents
      unit.stats.hp = unit.stats.hp or ""
      -- setColor(unit.color) --DEBUG
      -- love.graphics.rectangle("fill", (v.x-1) * cellSize + BATTLE.grid.offsetX + 10, (v.y-1) * cellSize + BATTLE.grid.offsetY + 10, 10, 10)
      love.graphics.draw(IMG[v.cell.contents.graphic], (v.x-1) * cellSize + BATTLE.grid.offsetX + 10, (v.y-1) * cellSize + BATTLE.grid.offsetY + 10)--, 10, 10)
      love.graphics.print(unit.stats.hp, (v.x-1) * cellSize + BATTLE.grid.offsetX + 10, (v.y-1) * cellSize + BATTLE.grid.offsetY + 30)
    elseif v.cell.contents.class == "hero" then
      love.graphics.rectangle("fill", (v.x-1) * cellSize + BATTLE.grid.offsetX + 10 + v.cell.contents.xOffset, (v.y-1) * cellSize + BATTLE.grid.offsetY + 10 + v.cell.contents.yOffset, 25, 25)
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
    setColor(v.cell.bgColor)
    love.graphics.rectangle("fill", (v.x-1) * cellSize + mainCommandsGrids.offsetX, (v.y-1) * cellSize + mainCommandsGrids.offsetY, cellSize, cellSize)

    setColor(v.cell.lineColor)
    love.graphics.rectangle("line", (v.x-1) * cellSize + mainCommandsGrids.offsetX, (v.y-1) * cellSize + mainCommandsGrids.offsetY, cellSize, cellSize)
    
    --these draw/print commands are so ugly, not to mention repetetive... find some way to abstract them or make them cleaner! TODO DRY it up
    
    --print the name of the battle command. i guess this is DEBUG? not sure yet :P
    if v.cell.contents then
      white()
      love.graphics.printf(v.cell.contents, (v.x-1) * cellSize + mainCommandsGrids.offsetX, (v.y-1) * cellSize + mainCommandsGrids.offsetY, cellSize, "center")
    end
      
  end
end

-----------------------------------------------------------------------------------------------------------

function drawBattleDebugInfo()
  local debugInfo = "hero stats:\n"
  debugInfo = debugInfo.."HP: "..HERO.stats.hp.."/"..HERO.stats.maxHP.."\n"
  debugInfo = debugInfo.."AP: "..HERO.stats.ap.."/"..HERO.stats.maxAP.."\n"  
  
  white()
  love.graphics.print(debugInfo, 10, cellSize * overworldZoom * 4 + 10)
end

-----------------------------------------------------------------------------------------------------------