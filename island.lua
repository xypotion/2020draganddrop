function initIsland()
  local island = new3x3Grid({initIslandArea()})

  local ids = {1, 2, 4}
--  for i = 1, 9 do table.insert(ids, i) end
  
  shuffle(ids)
  tablePrint(ids)
--  tablePrint({1, 2, 4}) WTF
  print(ids)

  return island
end

function initIslandArea()
  local grid = {}

  local size = 5

  --build out the grid itself & initialize cells 
  for y=1, size do
    grid[y] = {}
    for x=1, size do
      local r, g, b = math.random(), math.random(), math.random()
      grid[y][x] = {
        mouseOver = false,
        bgColor = {r, g, b, 0.25},
        bgHoverColor = {r, g, b, 0.5}
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