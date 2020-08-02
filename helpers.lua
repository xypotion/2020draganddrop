--stuff

function white()
  love.graphics.setColor(1,1,1)
end

function setColor(r,g,b,a)
  if not a then a = 1 end

  love.graphics.setColor(r,g,b,a)
end

--mutates the input, so ONLY use this in the form foo = shuffle(foo)
function shuffle(arr)
  local new = {}

  for i = 1, table.getn(arr) do
    new[i] = table.remove(arr, math.random(table.getn(arr)))
  end

  return new
end

-- function clear()
-- 	return {class = "clear"}
-- end
--
-- function empty()
-- 	return {contents = clear()}
-- end

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
function tablePrint(table, offset)
  offset = offset or "  "

  for k,v in pairs(table) do
    if type(v) == "table" then
      print(offset.."sub-table ["..k.."]:")
      tablePrint(v, offset.."  ")
    else
      print(offset.."["..k.."] = "..tostring(v))
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