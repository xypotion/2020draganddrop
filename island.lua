--an "island" is a collection of "island areas" (usually 3x3), each of which is a 5x5 grid of tiles

function initIsland()
  local island = new3x3Grid(initIslandArea())

  local ids = {}
  for i = 1, 9 do table.insert(ids, i) end
  	
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
	
	addOuterIslandBorder(island)
	
	tablePrint(island.areaNumbersReference)

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
      --add basic borders. explanation: if row or column 1 or 5, add block; otherwise clear
      -- if y % 4 == 1 or x % 4 == 1 then
			if y % 4 == 1 and x ~= 3 or x % 4 == 1 and y ~= 3 then --same but allows for basic connecting roads. this is DEBUG obviously
				local r, g, b = math.random(), math.random(), math.random()
				
	      cell.contents = {
					class = "block",
					color = {r, g, b, 1},
					fadeColor = {r, g, b, 0.5},
					yOffset = 0,
					xOffset = 0
				}
			else
	      cell.contents = {class = "clear"}
			end
    end
  end

  return grid
end

--the very outside tiles of the 3x3(5x5) supergrid need to be different
function addOuterIslandBorder(island)
	local outerBorderBlock = {
		class = "block",
		color = {0, 0, 0, 1},
		fadeColor = {0, 0, 0, 0.5},
    message = "I'M A BORDER CELL",
		yOffset = 0,
		xOffset = 0
	}
	
  for y, row in ipairs(island) do
    for x, area in ipairs(row) do
		  for areaY, areaRow in ipairs(area) do
		    for areaX, cell in ipairs(areaRow) do
					if (y == 1 and areaY == 1) or (y == 3 and areaY == 5) or (x == 1 and areaX == 1) or (x == 3 and areaX == 5) then
            cell.contents = deepClone(outerBorderBlock)
					end
				end
			end
		end
	end
	
	return island
end

function connectIslandAreas()
end