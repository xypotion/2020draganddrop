function mapAllPathsFrom(grid, start)
	local failsafe = 0
		
	local map = interpretGrid(grid)
		
	--set start point in the grid
	map[start.y][start.x].shortestDistanceFromStart = 0
	
	--DEBUG
	-- map[2][1].obstacle = true
	map[2][2].obstacle = true
	-- map[2][3].obstacle = true
		
	--prime...
	local current = start
	local uvn = nil
	
	--...and loop! until you run out of places to visit
	while(current and failsafe < 1000) do
		-- print("loop iteration "..failsafe)
		failsafe = failsafe + 1
		
		uvn = findNextsUnvisitedNeighbors(map, current)
			
		updateDistancesAndParentCell(uvn, map, current)
	
		--mark current as visited
		map[current.y][current.x].visited = true
		
		current = findUnvisitedCellWithShortestDistanceToCurrent(map)
	end
		
	tablePrint(map)
	
	return map
end

--make a copy of grid, noting obstacles
--for now, nothing is an obstacle. hopefully won't be too hard TODO later
function interpretGrid(grid)
	local copy = {}
	
	for k, y in ipairs(grid) do
		copy[k] = {}
		for j, x in ipairs(y) do
			copy[k][j] = {				
				shortestDistanceFromStart = 999,
				parentCell = nil,--{},
				visited = false,
				
				obstacle = false
			}
		end
	end
	
	return copy	
end

--
function findUnvisitedCellWithShortestDistanceToCurrent(g)
	local next = nil
	local shortestDistance = 999
	
	--check all cells, keeping only the one that's unvisited and nearest start
	for y, row in pairs(g) do
		for x, cell in pairs(row) do
			if not cell.visited and cell.shortestDistanceFromStart + 1 < shortestDistance then
				next = {y = y, x = x}
				shortestDistance = cell.shortestDistanceFromStart
			end
		end
	end	
	
	return next
end

--
function findNextsUnvisitedNeighbors(g, current)
	local uvn = {}
	
	table.insert(uvn, getCellIfValid(g, current.y - 1, current.x)) --north
	table.insert(uvn, getCellIfValid(g, current.y + 1, current.x)) --south
	table.insert(uvn, getCellIfValid(g, current.y, current.x + 1)) --east
	table.insert(uvn, getCellIfValid(g, current.y, current.x - 1)) --west
	
	--TODO try randomizing uvn before returning... maybe
	
	return uvn
end

function getCellIfValid(g, y, x)
	local c = nil
	
	if g and g[y] and g[y][x] and not g[y][x].obstacle and not g[y][x].visited then
		c = {y = y, x = x}
	end
	
	return c
end

function updateDistancesAndParentCell(neighbors, g, current)
	--loop through neighbors, updating each corresponding g member's shortestDistanceFromStart AND parent cell if there's a shorter one now
	for k, n in pairs(neighbors) do
		print(k)
		tablePrint(n)
		
		local dist = g[current.y][current.x].shortestDistanceFromStart + 1
		
		if dist < g[n.y][n.x].shortestDistanceFromStart then
			g[n.y][n.x].parentCell = current
			g[n.y][n.x].shortestDistanceFromStart = dist
		end
	end
end