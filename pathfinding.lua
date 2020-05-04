function mapAllPathsFromHero(grid)--, start)
	-- local failsafe = 0
		
	local map = interpretGrid(grid)
	-- local map = grid --TODO this should not be necessary
		
	--prime...
	local currentLocation = findHeroLocationInGrid(grid)--start
	map[currentLocation.y][currentLocation.x].shortestDistanceFromStart = 0
	local uvn = nil
	
	--...and loop, dijkstra-style! until you run out of places to visit
	while(currentLocation) do-- and failsafe < 100) do
		-- print("loop iteration "..failsafe)
		-- failsafe = failsafe + 1
		
		uvn = findNextsUnvisitedNeighbors(map, currentLocation)
		
		updateDistancesAndParentCell(uvn, map, currentLocation)
	
		--mark current as visited
		map[currentLocation.y][currentLocation.x].visited = true
		
		currentLocation = findUnvisitedCellWithShortestDistanceToCurrent(map)
	end
			
	return transferPathMapToGrid(map, grid)
end

function transferPathMapToGrid(m, g)
	--zip map into grid
	--or, zip "reverse paths into grid"
	for y, row in ipairs(m) do
		for x, cell in ipairs(row) do
			--get path TO this cell. push(path, step, 1) should put the last step at the beginning of the list, which is what we want
			local path = {{y = y, x = x}}
			
			--prime with map's matching cell
			local pc = cell.parentCell
			
			
			--and loop until there's no more parentCell
			while pc do --and failSafe < 100 do
				
				--push this parent cell to the beginning of the list, unless we have found the end
				if m[pc.y][pc.x].parentCell then
					--push a step in the path
					reversePush(path, pc)
				end
				
				--get next
				pc = m[pc.y][pc.x].parentCell
				
				-- failSafe = failSafe + 1
			end
			
			--deposit path in grid
			g[y][x].pathFromHero = path
		end
	end
	
	return g
end

function findHeroLocationInGrid(g)
	local heroLocation = nil
	
	-- tablePrint(g)
	
	for y, row in ipairs(g) do
		for x, cell in ipairs(row) do
			-- print(y,x)
			-- tablePrint(cell)
			if cell.contents.class == "hero" then
				heroLocation = {y = y, x = x}
			end
		end
	end
	
	return heroLocation
end

--make a copy of grid, noting obstacles
--for now, nothing is an obstacle. hopefully won't be too hard TODO later
function interpretGrid(g)
	local copy = {}
	
	for y, row in ipairs(g) do
		copy[y] = {}
		for x, cell in ipairs(row) do				
			copy[y][x] = {				
				shortestDistanceFromStart = 999,
				parentCell = nil,
				visited = false,
				
				obstacle = false
			}
			
			--shouldn't be necessary... TODO
			if cell.contents.class == "obstacle" then
				copy[y][x].obstacle = true
			end
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

--TODO actually look at cell contents
function getCellIfValid(g, y, x)
	local c = nil
	
	if g and g[y] and g[y][x] and not g[y][x].obstacle and not g[y][x].visited then
		c = {y = y, x = x}
	end
	
	return c
end

function updateDistancesAndParentCell(neighbors, g, current)
	--loop through neighbors, updating each corresponding g member's shortestDistanceFromStart AND parent cell if there's a shorter one now
	for i, n in pairs(neighbors) do
		local dist = g[current.y][current.x].shortestDistanceFromStart + 1
		
		if dist < g[n.y][n.x].shortestDistanceFromStart then
			g[n.y][n.x].parentCell = current
			g[n.y][n.x].shortestDistanceFromStart = dist
		end
	end
end