function primeAreaMoveEvent(dy, dx, nextArea)
  local e = {
    class = "primeAreaMove",
    -- currentArea = current,
    nextArea = nextArea,
    dy = dy,
    dx = dx
  }
  
  return e
end

function process_primeAreaMoveEvent(e)
  -- tablePrint(e, 2)
  
  PIA = CIA
  PIA.offsetY = 0
  PIA.offsetX = 0
  
  -- nextArea = currentIsland[(ciaCoords.y + dy - 1) % ISLANDSIZE + dy % 2][(ciaCoords.x + dx - 1) % ISLANDSIZE + dx % 2]
  
  CIA = e.nextArea
  CIA.offsetY = AREASIZE * cellSize * e.dy
  CIA.offsetX = AREASIZE * cellSize * e.dx
  
  
  -- print("PIA, CIA area numbers:", PIA.areaNumber, CIA.areaNumber)
  
  ---nextArea = currentIsland[(ciaCoords.y + dy - 1) % ISLANDSIZE + dy % 2][(ciaCoords.x + dx - 1) % ISLANDSIZE + dx % 2] 
  
  
  e.finished = true
end



---argh, how can this possibly be so tangled up? like 4 different approaches and i'm still not getting it right.

--[[
1. player clicks
2. queue up hero movement (fine. good.)
3. are we walking TO an edge? if no, do nothing else but queue a remap
4. if YES... 
  1. determine next grid (get a "nextarea" pointer?)...
  2. queue up hero's jump to next grid + animation for that. same "pull to destination" move
  3. queue up CURRENT grid's exit: it will need to be assigned to PIA and given moveFrames (in an areaMoveEvent) 
  4. queue up NEXT grid's entrance: it will need to be assigned to CIA and ''
...?
  5. still queue a remap after all that
]]

-----------------------------------------------------------------------------------------------------------

-- function areaMoveEvent(ciaCoords, island, direction)
function areaMoveEvent(area, dy, dx)
  -- local islandSize = table.getn(island) --should always be 3, but you know... just in case...
  
  -- local speed = 0.25
  
  local e = {
    class = "areaMove",
    area = area,
    -- dy = 0,
    -- dx = 0,
    -- cia = {}, --analogue to CIA, "current island area"
    -- nia = {}, --"next island area". reference to it must be stored in this event, but the variable "NIA" will be used for actual drawing
    -- destinationCell = {},
    -- moveFrames = areaSize / speed
    moveFrames = {}
  }
  

  
  local maxFrames = 10
  local increment = 0 - cellSize * AREASIZE / maxFrames
  
  for k = maxFrames - 1, 0, -1 do
    table.insert(e.moveFrames, {
      dy = dy * increment,
      dx = dx * increment
    })
  end
  -- print("areaMoveEvent...")
  -- tablePrint(e, 2)
    
  return e
end

function process_areaMoveEvent(e)
  -- NIA = e.nia
  --
  -- e.cia.offsetY = e.cia.offsetY - e.dy --...so these actually *negative* deltas. whatever.
  -- e.cia.offsetX = e.cia.offsetX - e.dx
  --
  -- e.nia.offsetY = e.nia.offsetY - e.dy
  -- e.nia.offsetX = e.nia.offsetX - e.dx
  --
  -- e.moveFrames = e.moveFrames - 1
  --
  -- -- tablePrint(currentIsland.areaNumbersReference)
  -- -- print(e.cia.areaNumber)
  -- -- print(e.nia.areaNumber)
  -- -- tablePrint(e)
  --
  -- if e.moveFrames == 0 then
  --   queue(gridOpEvent("remap"))
  --
  --   CIA = e.nia
  --   NIA = nil
  --
  --   e.finished = true
  --   print("area shift done")
  -- end
  
	local frame = pop(e.moveFrames)
	
  -- e.g[e.y][e.x].contents.pose = frame.pose
	e.area.offsetY = e.area.offsetY + frame.dy
	e.area.offsetX = e.area.offsetX + frame.dx
	
	if not peek(e.moveFrames) then
		e.finished = true
	end
end