function drawOverworld()
  love.graphics.setCanvas(overworldCanvas)  
  love.graphics.clear(0,0,0,1)

  --draw CIA, PIA cells' backgrounds and contents
  drawIslandAreaBackgrounds(CIA)

  if PIA then
    drawIslandAreaBackgrounds(PIA)
  end

  drawIslandAreaContents(CIA)

  if PIA then  
    drawIslandAreaContents(PIA)
  end

  white()

  --draw path to currently hovered destination
  if hoveredCell and CIA[hoveredCell.y][hoveredCell.x].pathFromHero then --TODO this second condition was not always necessary. investigate
    for i, step in pairs(CIA[hoveredCell.y][hoveredCell.x].pathFromHero) do
      love.graphics.circle("line", (step.x-0.5)*cellSize + CIA.offsetX, (step.y-0.5)*cellSize + CIA.offsetY, cellSize*0.45)
    end
  end

  white()

  --draw gameCanvas
  --TODO move ALL of this to drawOverworld :) ...better yet, in draw.lua, or even drawOverworld.lua
  love.graphics.setCanvas()
  love.graphics.draw(overworldCanvas, 0, 0, 0, overworldZoom, overworldZoom)
end

-----------------------------------------------------------------------------------------------------------

function drawIslandAreaBackgrounds(ia)
  for k, v in ipairs(allCellsInGrid(ia)) do
    if v.cell.mouseOver then --honestly this entire block is DEBUG. won't matter on a touchscreen
      setColor(v.cell.bgHoverColor)
    else
      setColor(v.cell.bgColor)
    end

    love.graphics.rectangle("fill", (v.x-1) * cellSize + ia.offsetX, (v.y-1) * cellSize + ia.offsetY, cellSize, cellSize)
  end
end

function drawIslandAreaContents(ia)
  for y, row in ipairs(ia) do
    for x, c in ipairs(row) do
      if c.contents and c.contents.class ~= "clear" then
        drawCellContents(c.contents, (y-0.5) * cellSize + ia.offsetY, (x-0.5) * cellSize + ia.offsetX)
      end
    end
  end
end

function drawStage()
end

function drawCellContents(obj, screenY, screenX)
  setColor(obj.color)

  if obj.class == "block" then
    love.graphics.rectangle("fill", screenX - cellSize/2, screenY - cellSize/2, cellSize, cellSize)
  elseif obj.class == "danger" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize * 0.4, 4)
  elseif obj.class == "npc" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.35)
  elseif obj.class == "item" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.15)
  elseif obj.class == "hero" then
    love.graphics.circle("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize * softOscillator)
  end
  -- love.graphics.polygon("fill", screenX + obj.xOffset, screenY + obj.yOffset, cellSize*0.45)
end