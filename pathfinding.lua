--need a dijkstra refresher? https://www.youtube.com/watch?v=pVfj6mxhdMwx

function mapAllPathsFromHero(grid)--, start)
  -- local failsafe = 0
  -- print("mapAllPathsFromHero") DEBUG

  local fastestMap = interpretGrid(grid)
  -- local map = grid --TODO this should not be necessary

  --prime...
  local currentLocation = findHeroLocationInGrid(grid)--start
  fastestMap[currentLocation.y][currentLocation.x].shortestDistanceFromStart = 0
  local uvn = nil
  
  -- tablePrint(currentLocation)

  --...and loop, dijkstra-style! until you run out of places to visit
  --summary: each cell is assigned a parent cell, which is the cell the hero would walk to IMMEDIATELY BEFORE walking to that cell
  --  parent cells are assigned by...
  while(currentLocation) do-- and failsafe < 100) do
    -- print("loop iteration "..failsafe)
    -- failsafe = failsafe + 1

    --does the current cell have any unvisited neighbors?
    uvn = findNextsUnvisitedNeighbors(fastestMap, currentLocation)

    updateUnvisitedNeighborsDistancesAndParentCells(uvn, fastestMap, currentLocation) --my, what a long function name you have

    --mark current as visited, then move on
    fastestMap[currentLocation.y][currentLocation.x].visited = true
    currentLocation = findUnvisitedCellWithShortestDistanceToCurrent(fastestMap)
  end
  
  
  
  --same as above but focused on SAFETY this time
  --if there are obstacles that should be avoided and are possible to avoid, this will find the safest, shortest way to do so
  -- local safetyMap = interpretGrid(grid)
  -- currentLocation = findHeroLocationInGrid(grid)
  -- safetyMap[currentLocation.y][currentLocation.x].shortestDistanceFromStart = 0
  -- uvn = nil
  --
  -- failSafe = 0
  --
  -- --basically the same as the first time, but consider tiles over danger threshold to be obstacles
  -- while(currentLocation and failSafe < 100) do
  --   --does the current cell have any unvisited neighbors?
  --   uvn = findNextsUnvisitedNeighborsUnderDangerThreshold(safetyMap, currentLocation)
  --
  --   updateUnvisitedNeighborsDistancesAndParentCells(uvn, safetyMap, currentLocation)
  --
  --   safetyMap[currentLocation.y][currentLocation.x].visited = true
  --   currentLocation = findUnvisitedCellWithShortestDistanceToCurrent(safetyMap)
  --
  --   failSafe = failSafe + 1
  -- end
  
  

  -- return transferPathMapToGrid(safetyMap, grid)
  -- return transferPathMapToGrid(map, grid)
  
  return transferBestPathsFromMapToGrid(grid, fastestMap, safetyMap)
end

function transferBestPathsFromMapToGrid(g, fm, sm)
  -- print("transferPathMapToGrid") DEBUG
  --zip map into grid
  --or, zip "reverse paths into grid"
  local finalGrid = g
  
  --prime grid's cells with empty path, since some might truly not be reachable
  for k, cell in pairs(allCellsInGrid(finalGrid)) do
    cell.pathFromHero = {}
  end
  
  --add whatever paths you have to the final grid
  transferPathMapToGrid(finalGrid, fm) --every reachable cell should have a fastest safe path...
  -- transferPathMapToGrid(finalGrid, sm) --...but if there's a danger-free path, use that, instead!
  
  return finalGrid
end
  
function transferPathMapToGrid(g, m)
  --for each cell in the map...
  for y, row in ipairs(m) do
    for x, cell in ipairs(row) do
      if cell.parentCell then
        --...get path TO this cell. push(path, step, 1) should put the last step at the beginning of the list, which is what we want (? TODO confirm/clarify)
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

  --just for DEBUG purposes...
  if not heroLocation then print("there's no hero in this grid, chief") end

  return heroLocation
end

--make a copy of grid, noting obstacles
--for now, nothing is an obstacle. hopefully won't be too hard TODO later
function interpretGrid(g)
  -- print("interpretGrid") DEBUG
  local copy = {}

  for y, row in ipairs(g) do
    copy[y] = {}
    for x, cell in ipairs(row) do				
      copy[y][x] = {				
        shortestDistanceFromStart = 999,
        parentCell = nil, --TODO rename to fastParentCell
        visited = false,
        
        lowestHazardTallyFromStart = 999,
        safeParentCell = nil,
        
        danger = cell.danger,

        obstacle = false -- basically DEBUG
      }

      --shouldn't be necessary... TODO
      if cell.contents.class == "block" 
      or cell.contents.class == "danger" 
      or cell.contents.class == "npc" then
        copy[y][x].obstacle = true
      end
    end
  end
  -- tablePrint(copy)
  return copy	
end








-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------








--not actually pathing logic, just finding next unvisited cell in order to continue the main loop (of finding a path to the hero from all cells in the grid)
function findUnvisitedCellWithShortestDistanceToCurrent(g)
  -- print("findUnvisitedCellWithShortestDistanceToCurrent")-- DEBUG
  local next = nil
  local shortestDistance = 999
  -- local lowestDanger = 999

  --check all cells, keeping only the one that's unvisited and nearest start
  for y, row in pairs(g) do
    for x, cell in pairs(row) do			
      if not cell.visited and cell.shortestDistanceFromStart < shortestDistance then
        next = {y = y, x = x}
        shortestDistance = cell.shortestDistanceFromStart
      end
    end
  end	
  -- tablePrint(next)

  return next
end

function findNextsUnvisitedNeighborsUnderDangerThreshold(g, current)
  print("findNextsUnvisitedNeighborsUnderDangerThreshold", current.y, current.x)
  return findNextsUnvisitedNeighbors(g, current, true)
end

--
function findNextsUnvisitedNeighbors(g, current, safetyMatters)
  print("findNextsUnvisitedNeighbors", current.y, current.x, safetyMatters) --DEBUG
  
  local uvn = {}

  table.insert(uvn, getCellIfValid(g, current.y - 1, current.x, safetyMatters)) --north
  table.insert(uvn, getCellIfValid(g, current.y + 1, current.x, safetyMatters)) --south
  table.insert(uvn, getCellIfValid(g, current.y, current.x + 1, safetyMatters)) --east
  table.insert(uvn, getCellIfValid(g, current.y, current.x - 1, safetyMatters)) --west

  --TODO try randomizing uvn before returning... maybe
  
  -- if not uvn[1] then --DEBUG
  --   print("APPARENTLY NO VALID NEIGHBORS FOR ", current.y, current.x)
  -- end

  return uvn
end

--TODO actually look at cell contents rather than just .obstacle
function getCellIfValid(g, y, x, safetyMatters)
  local c = nil
  
  -- print("getCellIfValid", safetyMatters)
  
  -- if safetyMatters then
  --   --ignore visited state
  --   if g and g[y] and g[y][x] and not g[y][x].obstacle and not g[y][x].visited then
  --     print(y, x, "is a valid neighbor...")--", maybe already visited?")
  --     c = {y = y, x = x, danger = g[y][x].danger}
  --     --TODO this seems so pointless?? where is the change i need to make? T_T
  --   end
  --
  -- else

    --is the cell unvisited and not an obstacle, i.e. valid?
    if g and g[y] and g[y][x] and not g[y][x].obstacle and not g[y][x].visited then
      -- print("in there?")
      -- if safetyMatters then
      -- if false then
      --   print("safe?")
      --   if g[y][x].danger < PATHING_DANGER_THRESHOLD then --there's got to be a more logically concise way of doing this, right? it's at least clear this way, but it feels clunky
      --     c = {y = y, x = x, danger = g[y][x].danger}
      --     print("ooh, safe")
      --   end
      -- else
      print(y, x, "is a valid neighbor")
      c = {y = y, x = x, danger = g[y][x].danger}
        -- print("safety doesn't matter, woo")
      -- end
      -- print("getCellIfValid...", y, x, "...was valid") DEBUG
    else
    -- tablePrint(g)
    end
  -- end

  return c
end

--supposed to be updating the current cell's neighbors' parent cells & shortest distances
--they might have a parent cell already, BUT there might be one that's... safer? closer to start?
function updateUnvisitedNeighborsDistancesAndParentCells(neighbors, g, current)
  -- print("updateUnvisitedNeighborsDistancesAndParentCells")--, current.y, current.x) DEBUG
  
  if not neighbors[1] then
    print(current.y, current.x, "HAS NO UNVISITED NEIGHBORS!") -- DEBUG
    return
  end
  
  -- find least dangerous neighbors' danger level
  -- local minDangerAmongNeighbors = 9999
  -- for i, n in pairs(neighbors) do
  --   if g[n.y][n.x].danger < minDangerAmongNeighbors then
  --     minDangerAmongNeighbors = g[n.y][n.x].danger
  --   end
  -- end
  -- print("minDangerAmongNeighbors", minDangerAmongNeighbors) DEBUG
  
  --loop through currentLocation's neighbors, updating each corresponding g member's shortestDistanceFromStart AND parent cell if there's a shorter one now
  -- local dist = g[current.y][current.x].shortestDistanceFromStart + 1
  local currentCellsShortestDistanceFromStart = g[current.y][current.x].shortestDistanceFromStart --+ 1
  if g[current.y][current.x].danger >= PATHING_DANGER_THRESHOLD then
    currentCellsShortestDistanceFromStart = currentCellsShortestDistanceFromStart + 100 
    --wow. i can't believe this was the solution all along. did i not try this already? >_< commit it
  else
    currentCellsShortestDistanceFromStart = currentCellsShortestDistanceFromStart + 1
  end

  --for each neighbor to currentLocation that hasn't been visited yet (i.e. hasn't BEEN currentLocation yet)...
  for i, n in pairs(neighbors) do
  -- for i, n in pairs(safestNeighbors) do
  
    -- local dist = g[n.y][n.x].shortestDistanceFromStart
    
    -- local danger = g[current.y][current.x].danger
    --[[
    if dist == g[n.y][n.x].shortestDistanceFromStart then
      --dist tie
      
      --is this tile one of the least dangerous?
      if g[n.y][n.x].danger == minDanger then
        g[n.y][n.x].parentCell = current
        g[n.y][n.x].shortestDistanceFromStart = dist
        print("    PING", current.y, current.x, n.y, n.x) --progress, kinda TODO TODO TODO i think this is the right track now, at least 9_9
        --wait, don't we actually want to totally avoid truly dangerous areas? maybe a threshold? this will matter when tiles are ACTUALLY dangerous TODO
        --what if we make one fast path, and then one safe path if the fast path is too dangerous? TODO
      end
    elseif dist < g[n.y][n.x].shortestDistanceFromStart then
      --??
      print("   ELSE CASE")
      g[n.y][n.x].parentCell = current
      g[n.y][n.x].shortestDistanceFromStart = dist
    end
    ]]
    
    --this neighbor needs a parent cell. if it doesn't have one yet...
    --see if current is SAFER than this neighbor's known parent cell. if it is, point to current
    --if it isn't, is current CLOSER than known parent cell? if it is, point to current
    --if neither, then don't change anything
    local nCell = g[n.y][n.x]
    local cCell = g[current.y][current.x]
    
    if nCell.parentCell then
      local pCell = g[nCell.parentCell.y][nCell.parentCell.x] --TODO not necessary, right?
      -- local pDanger = 
      --this neighbor already has a parent cell. how does current compare?
      -- if cCell.danger < pCell.danger then --TODO what i'm changing: not just each tile's danger, but the total danger of its path to the origin
      -- if pCell.danger >= PATHING_DANGER_THRESHOLD and cCell.danger < PATHING_DANGER_THRESHOLD then
      --   g[n.y][n.x].parentCell = current
      --   g[n.y][n.x].shortestDistanceFromStart = currentCellsShortestDistanceFromStart
      --   print("parent cell for", n.y, n.x, "WAS VERY DANGEROUS! setting parent to ", current.y, current.x)
      
      --TODO i think maybe keep this part? it was kind of triumphant when you got it TODO
      -- elseif tallyDangerOfPathToHeroForTile(g, current.y, current.x) < tallyDangerOfPathToHeroForTile(g, nCell.parentCell.y, nCell.parentCell.x) then
      --   g[n.y][n.x].parentCell = current
      --   g[n.y][n.x].shortestDistanceFromStart = currentCellsShortestDistanceFromStart
      --   print("parent cell for", n.y, n.x, "was DANGEROUS! setting parent to ", current.y, current.x)
      -- elseif
      -- if cCell.shortestDistanceFromStart + 1 < nCell.shortestDistanceFromStart then
      if currentCellsShortestDistanceFromStart < nCell.shortestDistanceFromStart then
        g[n.y][n.x].parentCell = current
        g[n.y][n.x].shortestDistanceFromStart = currentCellsShortestDistanceFromStart
        print("parent cell for", n.y, n.x, "was on a longer path; setting parent to ", current.y, current.x)
        --i think this never happens? lol TODO remove if true. i guess.
      end
    else
      --no parent cell yet, so just set to current
      g[n.y][n.x].parentCell = current
      g[n.y][n.x].shortestDistanceFromStart = currentCellsShortestDistanceFromStart
      print(n.y, n.x, "had no parent cell, so setting parent to ", current.y, current.x)
    end
    
    --OH MY GOD, FINALLY. F*CKING EUREKA. that took way too long to implement. it's at least basically working now.
    --what i think you actually have TODO is map out paths twice, however... once by safety (watching for a danger threshold), then once by distance
    --then when zipping the paths back into the source grid, give each the safe path IF IT EXISTS, otherwise give the shortest path. 
    --either way, rename to "best path" :)
    --but ah, keep the logic flexible enough so that the player can maybe change it via a setting
    
    --ok. it's late. made progress on 9/7, but the weekend is basically over. i'm probably not going to solve bug #2 tonight. :/
      
      
    --9/10, nth attempt to add hazard-based pathing...
    -- if nCell.safeParentCell then
--       --test... if LESSER danger, set; if EQUAL danger but closer, set; otherwise no-op
--       local nspCell = g[nCell.safeParentCell.y][nCell.safeParentCell.x] -- TODO redundant?
--
--       if cCell.lowestHazardTallyFromStart < nspCell.lowestHazardTallyFromStart
--       or cCell.lowestHazardTallyFromStart == nspCell.lowestHazardTallyFromStart and cCell.shortestDistanceFromStart + 1 < nCell.shortestDistanceFromStart
--       then
--         print(n.y, n.x, "'s current safe parent was not optimal, so i set it to ", current.y, current.x)
--
--         g[n.y][n.x].safeParentCell = current
--
--         --recalc danger
--         if cCell.danger >= PATHING_DANGER_THRESHOLD then
--           g[n.y][n.x].lowestHazardTallyFromStart = cCell.lowestHazardTallyFromStart + cCell.danger
--         else
--           g[n.y][n.x].lowestHazardTallyFromStart = cCell.lowestHazardTallyFromStart
--         end
--       end
--     else
--       print(n.y, n.x, "didn't have a SAFE parent cell yet, so i set it to ", current.y, current.x)
--     end
  end
  
  -- print("ok, final decision for "..current.y..", "..current.x.."'s parent cell: ", n.y, n.x) lol you forgot AGAIN how dijkstra works
  print("done setting ", current.y, current.x, "as neighbors' parent cell\n")
end

--so yeah, you are (or were) misunderstanding this function, i think. you're not trying to find "the safest neighbor" among uvn...
--rather, you're seeing if, for each unvisited neighbor, currentLocation is less dangerous than its current parent cell


--make it recursive? :)
function tallyDangerOfPathToHeroForTile(g, y, x)
  --kind of like how each node is sort of tracking its distance to the origin, this could be called (a lot) during above function to assess total danger
  --line 241 is what you want, i think. not just the single neighbor's danger rating, but the total danger of it and its ancestors
  local pCell = g[y][x].parentCell
  
  if pCell then
    return g[y][x].danger + tallyDangerOfPathToHeroForTile(g, pCell.y, pCell.x)
  else
    return g[y][x].danger
  end
end


--[[
9/10, still just kinda brainstorming because nothing else has worked so far

normal dijkstra: work outward from origin, "visiting" each cell once, setting cells' parents to whatever is closest to origin (current); obstacles are not valid neighbors and therefore (1) don't get parent cells and (2) can't be set as a neighor

avoid-hazards dijkstra: same, but treat hazards as obstacles (in addition to normal obstacles), BUT when making path, ignore start and finish. only the hazards you might step on in the middle need to be avoided
- the problem is that since paths are really just sequences of parents, simply treating all hazards as obstacles won't... work...?? or will it???
- what if you map normally with hazards = obstacles, but also give each hazard tiles an "exit" parent. that's only used for building the path later, not for continued mapping
  - when building the path later, look first for these "purely safe"/"exit" parents first for each tile, then map normally from there (or just map normally if there is no safe path)
- ah, wait... you still want to also MINIMIZE danger, i.e. if they have no choice but to cross hazards to get to the endpoint, choose the path with the fewest. test with 999999111 area, i guess
  - to achieve this... uh... tally danger, attempt to be 0 (non-hazards don't count), path normally?? no
so map extremely normally (not even twice), but give each parent a "fastParent" and "safeParent"? and totalHazardDistance?
- then build safe path
]]
