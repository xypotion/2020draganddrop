function initOverworldSystem()
  --TODO battle system has the BATTLE table. should there be an OVERWORLD one, too? or not necessary?
  
  --TODO this probably isn't who should control this canvas. genericize them somehow, like CANVASES[1], [2], etc
  overworldCanvas = love.graphics.newCanvas(cellSize * AREASIZE, cellSize * AREASIZE)
  overworldCanvas:setFilter("nearest")  
  
  currentIsland = initIsland()
  CIA = currentIsland[currentIsland.areaNumbersReference[1].y][currentIsland.areaNumbersReference[1].x] --because you should always start in area 1 :)

  queue(gridOpEvent(CIA, "add obstacles", {type = "item", threshold = 0.1}))
  queue(gridOpEvent(CIA, "remap"))

  --obviously DEBUG; put hero in middle of CIA
  CIA[3][3].contents = {
    class = "hero",
    color = {1,1,1,1},
    fadeColor = {1,1,1,0.5},
    message = "hero?",
    yOffset = 0,
    xOffset = 0
  }
end

function overworldClick(mx, my, button)
  local mCellX, mCellY = convertMouseCoordsToOverworldCoords(mx, my)

--[[
  this is complicated... what are we doing?
  1. you've clicked a blocked tile -> nothing happens.
  2. you've clicked an open tile in the interior; it's open and has a pathFromHero -> build a path & queue up movement, then remap that area
  3. you've clicked an open tile on a boundary -> do above, except also queue up areaMoveEvent stuff, then remap for the NEXT area
  4. you've clicked on the hero not on a boundary -> nothing happens
  5. you've clicked on the hero ON a boundary -> send them back across that boundary to the neighboring area
  so logic... first check cell contents' class
    if blocked then do nothing
    if hero then 
      if on boundary
        area move, remap in new area
      else do nothing
    if clear then
      map there
      if boundary and not starting at boundary then
        area move
        remap in new area
      else
        remap in current area
      end
    end
  
  eh. try this?
  ]]  

  local cell = cellAt(mCellY, mCellX) 
  
  if cell then          
    --ok, what kind of cell is this?
    if cell.contents.class == "blocked" then
      --no-op :)
      
    elseif cell.contents.class == "hero" then
      --usually do nothing, unless we're on a border, in which case cross it again
      local dy, dx = 0, 0

      if mCellY == 1 then
        dy = -1
      elseif mCellY == 5 then
        dy = 1
      elseif mCellX == 1 then
        dx = -1
      elseif mCellX == 5 then
        dx = 1
      end
      
      if (dy ~= 0 or dx ~= 0) then
        queueNextAreaMoveAndRemapEvents(dy, dx, mCellY, mCellX)
      end
      
    elseif cell.contents.class == "clear" and cell.pathFromHero[1] then
      local starty = findHeroLocationInGrid(CIA)
      
      --queue up move/swap events from step to step along path
      for i, step in ipairs(CIA[mCellY][mCellX].pathFromHero) do      
        moveThingAtYX(starty.y, starty.x, step.y - starty.y, step.x - starty.x)

        starty = step
      end
      
      --now check for area move & do that if needed, then remap one way or the other
      local endy = findHeroLocationInGrid(CIA)
      local dy, dx = 0, 0

      --are we going to a border cell from a not-border cell?
      if mCellY == 1 and endy.y ~= 1 then
        dy = -1
      elseif mCellY == 5 and endy.y ~= 5 then
        dy = 1
      elseif mCellX == 1 and endy.x ~= 1 then
        dx = -1
      elseif mCellX == 5 and endy.x ~= 5 then
        dx = 1
      end
      
      if (dy ~= 0 or dx ~= 0) then
        queueNextAreaMoveAndRemapEvents(dy, dx, mCellY, mCellX)
      else
        queue(gridOpEvent(CIA, "remap"))
      end
    end
  end
end


--called for queueing move events after input is given
function moveThingAtYX(y, x, dy, dx, max)
  local ty, tx = y + dy, x + dx --t as in "target"

  --max = the number of movement frames it'll take this movement to finish
  max = max or maxFramesForHeroMove

  local moveFrames = {}

  for k = max - 1, 0, -1 do
    push(moveFrames, {
        pose = "idle", 
        yOffset = dy * -(cellSize * k / max), 
        xOffset = dx * -(cellSize * k / max)
      })
  end

  --queue pose and cell ops
  queueSet({
      cellSwapEvent(CIA, y, x, ty, tx), --eventually swapping won't work, but ok for now. DEBUG
      spriteMoveEvent(CIA, ty, tx, moveFrames)
    })

  processNow()
end

--dy and dx describe the way the hero is moving... we're moving to a neighboring map, but which way?
function queueNextAreaMoveAndRemapEvents(dy, dx, heroY, heroX)
  local ciaCoords = currentIsland.areaNumbersReference[CIA.areaNumber]
  local nextArea = currentIsland[(ciaCoords.y + dy - 1) % ISLANDSIZE + 1][(ciaCoords.x + dx - 1) % ISLANDSIZE + 1]
  
  queueSet({
      primeAreaMoveEvent(dy, dx, nextArea),
      areaMoveEvent(nextArea, dy, dx), --by the time this processes, nextArea will be CIA (because of the primer)
      areaMoveEvent(CIA, dy, dx), --by the time this processes, CIA will be PIA
      areaTransferEvent(CIA, heroY, heroX, nextArea, (heroY + dy - 1) % AREASIZE + 1, (heroX + dx - 1) % AREASIZE + 1),
      --TODO still need a hero animation event! should be easy, though
    })
  queue(gridOpEvent(nextArea, "remap"))
end

-- else
-- 	if grabbedThing and grabbedThing.item then
-- 		if cellAt(mCellX, mCellY) then
-- 			queue(cellSwapEvent(GRIDS.debug, mCellY, mCellX, grabbedThing.originY, grabbedThing.originX))
-- 		end
--
-- 		grabbedThing = nil
-- 		processNow()
-- 	end
--
-- 	-- grabbedThing = nil
-- 	-- mouseDownAtX, mouseDownAtY = 0, 0 --i really feel like there should be a more efficient way to do this...
-- 	mouseDownTimer = 0
-- 	mouseStillDown = false
-- 	mouseHasntMovedFar = false
--
-- 	processNow() --probably not necessary? or should be done higher up
-- end

function convertMouseCoordsToOverworldCoords(mx, my)
  local x = math.floor((mx-CIA.offsetX+cellSize*overworldZoom)/cellSize/overworldZoom)
  local y = math.floor((my-CIA.offsetY+cellSize*overworldZoom)/cellSize/overworldZoom)

  return x, y
end
