--stuff

function white()
  love.graphics.setColor(1,1,1)
end

function setColor(r,g,b,a)
  if type(r) == "table" then
    if r.r then
      if r.a then
        love.graphics.setColor(r.r,r.g,r.b,r.a)
      else
        love.graphics.setColor(r.r,r.g,r.b,1)
      end
    else
      love.graphics.setColor(r[1],r[2],r[3],r[4])
    end
  else
    if a then 
      love.graphics.setColor(r,g,b,a)
    else
      love.graphics.setColor(r,g,b,1)
    end
  end 
end

--mutates the input, so ONLY use this in the form foo = shuffle(foo)
function shuffle(arr)
  local new = {}

  for i = 1, table.getn(arr) do
    new[i] = table.remove(arr, math.random(table.getn(arr)))
  end

  return new
end

function empty(t)
  local e = true
  for k, v in pairs(t) do
    e = false
  end

  return e
end

function peek(q)
  return q[1]
end

--why the hell is this so complicated? TODO
function pop(q)
  local item = q[1]

  for i = 2, table.getn(q) do
    q[i - 1] = q[i]
  end

  q[table.getn(q)] = nil

  return item
end

--TODO maybe find better names for these two functions...
function push(q, item)
  table.insert(q, item)
end

--basically just inserting at the other end from push()
function reversePush(q, item)
  table.insert(q, 1, item)
end

--an old debug-helper function i made in 2014 :)
--reminder: never pass _G here, or other weird/global/self-nested tables here 
function tablePrint(table, depth, offset)
  if not depth then
    depth = 16
  else
    depth = depth - 1
  end

  offset = offset or "  "
  
  if not table then
    print(table)
    return
  end

  if depth > 0 then
    for k,v in pairs(table) do
      if type(v) == "table" then
        print(offset.."sub-table ["..k.."]:")
        tablePrint(v, depth, offset.."  ")
      else
        print(offset.."["..k.."] = "..tostring(v))
      end
    end
  end	
end

--returns either the floor or ceiling of input, with weighted randomness based on remainder. 
--e.g. rollRound(1.11) will usually round to 1, but you'll sometimes get 2, instead
function rollRound(num)
  local remainder = num % 1

  if math.random() <= remainder then
    return math.ceil(num)
  else
    return math.floor(num)
  end
end

--obviously never pass anything to this that's got looping references
--will not clone deeper than 16 levels (TODO test this)
function deepClone(original, safety)
  if safety then
    if safety > 16 then
      print("clone is too deep! returning nil")
      return nil
    end
  else
    safety = 0
  end

  local clone = {}

  for k, v in pairs(original) do
    if type (v) == "table" then
      clone[k] = deepClone(v, safety + 1)
    else
      clone[k] = v
    end
  end

  return clone
end

-----------------------------------------------------------------------------------------------------------

function new3x3Grid(cellPrimer)
  return newGrid(3, 3, cellPrimer)
end

function newGrid(height, width, cellPrimer)
  -- if not height then height, width = 3, 3 end
  cellPrimer = cellPrimer or {}

  local g = {}

  for y = 1, height do
    g[y] = {}
    for x = 1, width do
      g[y][x] = deepClone(cellPrimer)
    end
  end

  return g
end

-- function clear()
-- 	return {class = "clear"}
-- end
--
-- function empty()
-- 	return {contents = clear()}
-- end