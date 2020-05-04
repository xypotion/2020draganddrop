function cellOpEvent(grid, y, x, payload)
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