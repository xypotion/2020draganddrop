--an "island" is a collection of "island areas" (usually 3x3), each of which is a 5x5 grid of tiles

function initIsland()
  local island = new3x3Grid(initIslandArea) --initIslandArea is a FUNCTION that will be called once for each member

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

  -- tablePrint(island.areaNumbersReference) --DEBUG useful

  return island
end

--each island gets 9 of these
--each islandArea is designed to be manipulated and drawn on its own
function initIslandArea()
  local grid = {
    offsetX = 0,
    offsetY = 0,}

  local size = 5 --TODO make this more global... gridOps and other places refer to it

  --build out the grid itself & initialize cells
  for y=1, size do
    grid[y] = {}
    for x=1, size do
      local r, g, b = 0.5 * math.random(), 0.75 + math.random(), 0.5 * math.random()
      grid[y][x] = {
        mouseOver = false,
        bgColor = {r, g, b, 0.25},
        bgHoverColor = {r, g, b, 0.5},
        -- danger = (y+1)%2 + (x+1)%2, --helps with pathing by making the middle tile the least dangerous by default
        danger = math.random(9), -- DEBUG for testing danger-pathing
      }
      
      if grid[y][x].danger >= PATHING_DANGER_THRESHOLD then
        grid[y][x].danger = grid[y][x].danger * 9
      end
    end
  end
  
  --ADD CONTENTS to the grid
  for y, row in ipairs(grid) do
    for x, cell in ipairs(row) do
      --add basic borders. explanation: if row or column 1 or 5, add block; otherwise clear
      -- if y % 4 == 1 or x % 4 == 1 then
      if y % 4 == 1 and x ~= 3 or x % 4 == 1 and y ~= 3 then --same but allows for basic connecting roads. this is DEBUG obviously
        local r, g, b = 0.25 + 0.25 * math.random(), 0.125 + 0.25 * math.random(), 0.125 * math.random()

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
    color = {0, 0, 0.25, 1},
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
            cell.contents.color[3] = 0.5 + 0.25 * math.random() --a little ~bluer~ (DEBUG)
          end
        end
      end
    end
  end

  return island
end

function connectIslandAreas()
end