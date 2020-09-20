function particleEvent(y, x, params)
  local e = {
    class = "particle",
    y = y,
    x = x,
    params = params
  }
  
  return e
end

function process_particleEvent(e)
  -- table.insert(particles, newParticle(e.y, e.x, e.params))
  -- table.insert(particles, newParticle(e.y, e.x, e.params))
  -- table.insert(particles, newParticle(e.y, e.x, e.params))
  --TODO obviously actually enumerate these in e
  
  newParticleFoo(e.y, e.x, e.params) --TODO "params" seems inappropriate here...
  
  --TODO add internal timer here? or just release & finish when count = 0? or some other threshold? ("you've emitted your last, now die")
  --timer kinda seems better, but you'd need to pass in dt. wait, why aren't you passing in dt?
  
  e.finished = true
end


---------------------------------------------------------------------------------------------------


--TODO add continuous particle spawner somehow. OK to go in this file i think


---------------------------------------------------------------------------------------------------


--TODO floating damage numbers will probably be a kind of particle effect (? i guess), but allow for DELAYS in spawning, so they can appear at certain points during animations!


---------------------------------------------------------------------------------------------------


--TODO i guess move this elsewhere. it shouldn't go in an event file, probably
--TODO ...and more importantly, there are going to be a ton of different particle types. gotta make data files for that or something. so basically all of this will be scrapped eventually, lol
function newParticleFoo(y, x, name)
  -- local p = {y = y, x = x, w = 10, h = 10, ttl = 0.25, color = white()}
  local ps = love.graphics.newParticleSystem(IMG.dot)
  ps:setPosition(x, y)
  ps:setEmissionRate(0)
  ps:setParticleLifetime(1)
  
  -- if name == "old bash" then
  --   -- TODO filename for graphic or something
  --
  --   p.dy = (math.random() - 0.5) * 300
  --   p.dx = (math.random() - 0.5) * 300
  --   p.ay = 0 - p.dy
  --   p.ax = 0 - p.dx
  --   -- p.dy = p.dy * 4
  --   -- p.dx = p.dx * 4
  -- elseif name == "fireball" then
  --   -- TODO filename for graphic or something
  --
  --   p.dy = (math.random() - 0.5) * 300
  --   p.dx = (math.random() - 0.5) * 300
  --   p.ay = 0 - p.dy
  --   p.ax = 0 - p.dx
  --   -- p.dy = p.dy * 4
  --   -- p.dx = p.dx * 4
  --   p.color = {r = math.random() + 0.5, g = math.random() - 0.5, b = 0}
  if name == "bash" then
    -- p.dy = (math.random() - 0.5) * 300
    -- p.dx = (math.random() - 0.5) * 300
    -- p.ay = 0 - p.dy
    -- p.ax = 0 - p.dx
    -- p.dy = p.dy * 4
    -- p.dx = p.dx * 4
    -- p.color = {r = math.random() + 0.5, g = math.random() - 0.5, b = 0}
    
    ps:setSpread(10)
    ps:setSizes(6, 9)
    ps:setSpeed(81, 81)
    -- ps:setLinearDamping(1)
    ps:setColors(1,1,1,1, math.random(),math.random(),math.random(),0.25)
    -- ps:setEmissionArea("normal", 1, 1, 1, true)
    ps:setParticleLifetime(0.25)
    
    ps:emit(9)
    
  elseif name == "fireball" then
    ps:setDirection(PI*3/2)
    ps:setSpread(1)
    ps:setSizes(12, 6, 0)
    ps:setSpeed(81)
    ps:setColors(8/9,7/9,0,1,   2/3,1/3,0,2/3,   1,0,0,0)
    ps:setParticleLifetime(0.5)
    ps:setEmissionRate(81)
    ps:setEmissionArea("normal", 9, 0, 0)--, true)
    ps:setPosition(x, y+18)
    
    ps:setEmitterLifetime(2)
    ps:emit(9)
  else
    print("\""..name.."\" is not a real particle type, dude. giving you \"bash\".")
    return newParticleFoo(y, x, "bash")
  end
  
  -- return p
  
  table.insert(PARTICLESYSTEMS, ps)
end

--TODO in your brain: think of different color-change modes, e.g. fading away, cooling off, etc... it might be best to make verbal shortcuts for these things than numerically define dr, dg, db, da for every particle type
--same for size change, i think, and maybe other things! like acceleration (slow down, speed up). velocity can probably stay numeric :)
--TODO math.random for dy and dx is not great. better: choose a random direction and use trigonometry to set dx and dy! that way things will at least spread circularly. I'M A GENIUS (lol no)




function newTravelingParticleSystem()
  --fling those fireballs
end




function initParticleSystemSystem()
  PARTICLESYSTEMS = {}
end

function updateAllParticleSystems(dt)
  for k, ps in ipairs(PARTICLESYSTEMS) do
    ps:update(dt)
  end
end