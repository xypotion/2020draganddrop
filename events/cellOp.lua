function cellOpEvent(g, y, x, payload)
	local e = {
		class = "cellOp",
		grid = g,
		y = y,
		x = x,
		payload = payload
	}
	
	return e
end

function process_cellOpEvent(e)
	-- tablePrint(e)
	-- cellAt(e.y, e.x).contents = e.payload
	e.grid[e.y][e.x].contents = e.payload
		
	e.finished = true
end

-----------------------------------------------------------------------------------------------------------

--swap the contents of cells 1 and 2 in grid g
function cellSwapEvent(g, y1, x1, y2, x2)
	local e = {
		class = "cellSwap",
		grid = g,
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