require "draw/drawOverworld"

function love.draw()
  drawOverworld()
  
  --other canvases... grids, menus
  
  --particle effects
  
  --flying text, and just text of all kinds
  
  
  -- old drag-and-drop test. will need parts of this later!
  --things in grid
  -- for y=1, 3 do
  -- 	for x=1, 3 do
  -- 		if GRIDS.debug[y][x].contents and GRIDS.debug[y][x].contents.color then
  -- 			love.graphics.setColor(GRIDS.debug[y][x].contents.color)
  -- 			love.graphics.circle("fill", (x-0.5)*cellSize + GRIDS.debug.offsetX, (y-0.5)*cellSize + GRIDS.debug.offsetY, cellSize*0.45)
  -- 		end
  -- 	end
  -- end
  --
  -- --grabbedThing
  -- if grabbedThing then
  -- 	local mx, my = love.mouse.getPosition()
  -- 	-- tablePrint(grabbedThing)
  -- 	setColor(grabbedThing.item.fadeColor)
  -- 	love.graphics.circle("fill", mx - grabbedThing.relMouseX + cellSize/2, my - grabbedThing.relMouseY + cellSize/2, cellSize*0.45)
  -- end
  -- end
end

-----------------------------------------------------------------------------------------------------------
