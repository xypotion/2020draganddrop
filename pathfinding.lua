--need a dijkstra refresher? https://www.youtube.com/watch?v=pVfj6mxhdMwx

function mapAllPathsFromHero(grid)--, start)
  local failsafe = 0
  -- print("mapAllPathsFromHero") DEBUG

  local fastestMap = interpretGrid(grid) --still kinda feels like this shouldn't be necessary, but... if it ain't broke...

  --prime...
  local currentLocation = findHeroLocationInGrid(grid)--start
  fastestMap[currentLocation.y][currentLocation.x].shortestDistanceFromStart = 0
  local uvn = nil
  
  -- tablePrint(currentLocation)

  --...and loop, dijkstra-style! until you run out of places to visit
  --summary: each cell is assigned a parent cell, which is the cell the hero would walk to IMMEDIATELY BEFORE walking to that cell
  --  parent cells are assigned by...
  while(currentLocation and failsafe < 100) do
    -- print("loop iteration "..failsafe) DEBUG useful
    failsafe = failsafe + 1

    --does the current cell have any unvisited neighbors?
    uvn = findNextsUnvisitedNeighbors(fastestMap, currentLocation)

    updateUnvisitedNeighborsDistancesAndParentCells(uvn, fastestMap, currentLocation) --my, what a long function name you have

    --mark current as visited, then move on
    fastestMap[currentLocation.y][currentLocation.x].visited = true
    currentLocation = findUnvisitedCellWithShortestDistanceToCurrent(fastestMap)
  end
  
  return transferPathMapToGrid(grid, fastestMap)
end
  
function transferPathMapToGrid(g, m)
  --for each cell in the map...
  for y, row in ipairs(m) do
    for x, cell in ipairs(row) do
      cell.pathFromHero = {}
      
      if cell.parentCell then
        --...get path TO this cell. push(path, step, 1) should put the last step at the beginning of the list
        local path = {{y = y, x = x}}

        --prime with map's matching cell...
        local pc = cell.parentCell

        --...and loop until there's no more parentCell, i.e. until you reach the hero
        local failSafe = 0
        while pc and failSafe < 100 do
          --push this parent cell to the beginning of the list, unless we have found the end
          if m[pc.y][pc.x].parentCell then
            --add a step in the path
            reversePush(path, pc)
          end

          --get the parent's parent
          pc = m[pc.y][pc.x].parentCell

          failSafe = failSafe + 1 --because you never know when you'll screw this up somehow! lol
        end

        --deposit path in actual grid cell
        g[y][x].pathFromHero = path
      else
        --(unless there's no parent cell at all; "you can't get there from here")
        g[y][x].pathFromHero = {}
      end
    end
  end

  return g
end

function findHeroLocationInGrid(g)
  -- print("findHeroLocationInGrid") DEBUG
  local heroLocation = nil

  for y, row in ipairs(g) do
    for x, cell in ipairs(row) do
      if cell.contents.class == "hero" then
        heroLocation = {y = y, x = x}
      end
    end
  end

  --just for DEBUG purposes...
  if not heroLocation then print("THERE'S NO HERO IN THIS GRID, CHIEF") end

  return heroLocation
end

--make a copy of grid, noting obstacles
function interpretGrid(g)
  -- print("interpretGrid") DEBUG
  local copy = {}

  for y, row in ipairs(g) do
    copy[y] = {}
    for x, cell in ipairs(row) do				
      copy[y][x] = {				
        shortestDistanceFromStart = 999,
        parentCell = nil,
        visited = false,
                
        danger = cell.danger,

        obstacle = false -- basically DEBUG
      }

      --is there something here that we can't walk over?
      if cell.contents.class == "block" 
      or cell.contents.class == "danger" 
      or cell.contents.class == "npc" then
        copy[y][x].obstacle = true
      end
    end
  end

  return copy	
end


-----------------------------------------------------------------------------------------------------------


--not actually pathing logic, just finding next unvisited cell in order to continue the main loop (of finding a path to the hero from all cells in the grid)
function findUnvisitedCellWithShortestDistanceToCurrent(g)
  -- print("findUnvisitedCellWithShortestDistanceToCurrent")-- DEBUG
  local next = nil
  local shortestDistance = 999

  --check all cells, keeping only the one that's unvisited and nearest start
  for y, row in pairs(g) do
    for x, cell in pairs(row) do			
      if not cell.visited and cell.shortestDistanceFromStart < shortestDistance then
        next = {y = y, x = x}
        shortestDistance = cell.shortestDistanceFromStart
      end
    end
  end	

  return next
end

function findNextsUnvisitedNeighbors(g, current, safetyMatters)
  -- print("findNextsUnvisitedNeighbors", current.y, current.x) --DEBUG
  
  local uvn = {}

  table.insert(uvn, getCellIfValid(g, current.y - 1, current.x)) --north
  table.insert(uvn, getCellIfValid(g, current.y + 1, current.x)) --south
  table.insert(uvn, getCellIfValid(g, current.y, current.x + 1)) --east
  table.insert(uvn, getCellIfValid(g, current.y, current.x - 1)) --west
  
  return uvn
end

--TODO actually look at cell contents rather than just .obstacle
function getCellIfValid(g, y, x, safetyMatters)
  local c = nil
  
  --is the cell unvisited and not an obstacle, i.e. valid?
  if g and g[y] and g[y][x] and not g[y][x].obstacle and not g[y][x].visited then
    c = {y = y, x = x, danger = g[y][x].danger}
  end

  return c
end

--supposed to be updating the current cell's neighbors' parent cells & shortest distances
--they might have a parent cell already, BUT there might be one that's... safer? closer to start?
function updateUnvisitedNeighborsDistancesAndParentCells(neighbors, g, current)
  -- print("updateUnvisitedNeighborsDistancesAndParentCells")--, current.y, current.x) DEBUG
  
  --did we not get any neighbors? bail if so
  if not neighbors[1] then
    return
  end
  
  local cCell = g[current.y][current.x]
    
  --loop through current's valid neighbors, updating each corresponding g member's shortestDistanceFromStart AND parent cell if there's a shorter one now
  --currentCellsShortestDistanceFromStart is for decision-making in a moment; IF current is a hazard of some kind, make it seem much farther away...
  --...i.e. harder to reach, i.e. "don't go that way if you have a choice"
  local currentCellsShortestDistanceFromStart = g[current.y][current.x].shortestDistanceFromStart --+ 1
  if g[current.y][current.x].danger >= PATHING_DANGER_THRESHOLD then
    currentCellsShortestDistanceFromStart = currentCellsShortestDistanceFromStart + 100 --TODO it does feel a little hacky. at some point, when there are multiple hazard types that can be ranked, change this
    --ok.. so to fix bug 4, you need to increase danger levels a lot. 1-9 doesn't cut it; hazards need to be at least 10x normal. just noting this here in case it's ever an issue again!
  else
    currentCellsShortestDistanceFromStart = currentCellsShortestDistanceFromStart + 1
  end

  --for each neighbor to currentLocation that hasn't been visited yet (i.e. hasn't BEEN currentLocation yet)...
  for i, n in pairs(neighbors) do   
    local nCell = g[n.y][n.x]
    
    --this neighbor needs a parent cell. does it have one yet?    
    if nCell.parentCell then
      --it does! what's it like?

      --first, see if current is SAFER than this neighbor's known parent cell. if it is, point to current
      --the point of this is to make the hero walk through the middle tile of each area if the path is safe, rather than a weird zig-zag
      if tallyDangerOfPathToHeroForTile(g, current.y, current.x) < tallyDangerOfPathToHeroForTile(g, nCell.parentCell.y, nCell.parentCell.x) then
        nCell.parentCell = current
        nCell.shortestDistanceFromStart = currentCellsShortestDistanceFromStart
        -- print("parent cell for", n.y, n.x, "was dangerous! setting parent to ", current.y, current.x)

      --next, see if current cell is CLOSER than known parent cell; if it is, redirect to current
      --again, currentCellsShortestDistanceFromStart will be way bigger if the current tile is a hazard that needs to be avoided (this is by design. thanks, Dijkstra)
      elseif currentCellsShortestDistanceFromStart < nCell.shortestDistanceFromStart then
        nCell.parentCell = current
        nCell.shortestDistanceFromStart = currentCellsShortestDistanceFromStart
        -- print("parent cell for", n.y, n.x, "was on a longer or hazardous path; setting parent to ", current.y, current.x)
      end
    else
      --neighbor had no parent cell yet, so just set to current
      nCell.parentCell = current
      nCell.shortestDistanceFromStart = currentCellsShortestDistanceFromStart
      -- print(n.y, n.x, "had no parent cell, so setting parent to ", current.y, current.x)
    end
  end
  
  -- print("done setting ", current.y, current.x, "as neighbors' parent cell\n")
end

--just follow the path back to the origin, adding up each tile's "danger" rating
function tallyDangerOfPathToHeroForTile(g, y, x)
  local pCell = g[y][x].parentCell
  
  if pCell then
    return g[y][x].danger + tallyDangerOfPathToHeroForTile(g, pCell.y, pCell.x)
  else
    return g[y][x].danger
  end
end