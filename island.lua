--an "island" is a collection of "island areas" (usually 3x3), each of which is a 5x5 grid of tiles

function initIsland()
  -- local island = new3x3Grid(initIslandArea())
  local island = newGrid(5, 5, initIslandArea())

  local ids = {}
  for i = 1, 9 do table.insert(ids, i) end
  
	-- tablePrint(ids)
	
	-- assign random ids to island areas
  ids = shuffle(ids)
	
	local i = 1
	island.areaNumbersReference = {}
	
	for y = 1, 3 do
		for x = 1, 3 do
			island[y][x].areaNumber = ids[i]
			island.areaNumbersReference[ids[i]] = {y = y, x = x}
			
			i = i + 1
		end
	end
	
	-- tablePrint(island.areaNumbersReference)
	-- print(island.areaNumbersReference[])

  return island
end

function initIslandArea()
  local grid = {
			 offsetX = 0,
			 offsetY = 0,}

  local size = 5

  --build out the grid itself & initialize cells 
  for y=1, size do
    grid[y] = {}
    for x=1, size do
      local r, g, b = math.random(), math.random(), math.random()
      grid[y][x] = {
       mouseOver = false,
       bgColor = {r, g, b, 0.25},
       bgHoverColor = {r, g, b, 0.5},
      }
    end
  end

  --ADD CONTENTS to the grid
  for y, row in ipairs(grid) do
    for x, cell in ipairs(row) do
      local t = {class = "clear"}

      cell.contents = t
    end
  end

  return grid
end

function connectIslandAreas()
end