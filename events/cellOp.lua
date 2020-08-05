function cellOpEvent(grid, y, x, payload) --TODO rename? this is vague. actually everything here is vague...
  local e = {
    class = "cellOp",
    grid = grid,
    y = y,
    x = x,
    payload = payload
  }

  return e
end

function process_cellOpEvent(e)
  e.grid[e.y][e.x].contents = e.payload

  e.finished = true
end

-----------------------------------------------------------------------------------------------------------

--swap the CONTENTS of cells 1 and 2 in grid g
function cellSwapEvent(grid, y1, x1, y2, x2)
  local e = {
    class = "cellSwap",
    grid = grid,
    y1 = y1, 
    x1 = x1, 
    y2 = y2,
    x2 = x2
  }

  return e
end

function process_cellSwapEvent(e)
  e.grid[e.y1][e.x1].contents, e.grid[e.y2][e.x2].contents = e.grid[e.y2][e.x2].contents, e.grid[e.y1][e.x1].contents

  e.finished = true
end

-----------------------------------------------------------------------------------------------------------

--transfer contents of a cell in one grid to a cell in another grid
function areaTransferEvent(sg, sy, sx, dg, dy, dx) --source and destination: grid, y, and x
  local e = {
    class = "areaTransfer",
    sourceGrid = sg, 
    sourceY = sy, 
    sourceX = sx, 
    destGrid = dg, 
    destY = dy,
    destX = dx, 
  }

  return e
end

function process_areaTransferEvent(e)
  e.destGrid[e.destY][e.destX].contents = e.sourceGrid[e.sourceY][e.sourceX].contents
  e.sourceGrid[e.sourceY][e.sourceX].contents = {class = "clear"} 
  --you COULD make this event swappy, but it'll basically only be used for hero movement, so maybe doesn't matter

  e.finished = true
end