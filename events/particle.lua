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
  newParticleType(e.y, e.x, e.params) --TODO "params" seems inappropriate here...
  
  --TODO add internal timer here? or just release & finish when count = 0? or some other threshold? ("you've emitted your last, now die")
  --timer kinda seems better, but you'd need to pass in dt. wait, why aren't you passing in dt?
  
  e.finished = true
end


---------------------------------------------------------------------------------------------------


--TODO add continuous particle spawner somehow. OK to go in this file i think


---------------------------------------------------------------------------------------------------


--TODO i guess move this elsewhere. it shouldn't go in an event file, probably
--TODO ...and more importantly, there are going to be a ton of different particle types. gotta make data files for that or something. so basically all of this will be scrapped eventually, lol
function newParticleType(y, x, name)
  -- local p = {y = y, x = x, w = 10, h = 10, ttl = 0.25, color = white()}
  local ps = love.graphics.newParticleSystem(IMG.dot)
  ps:setPosition(x, y)
  ps:setEmissionRate(0)
  ps:setParticleLifetime(1)
  
  if name == "bash" then
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
    
  elseif name == "blizzard" then
    ps:setDirection(1)
    ps:setLinearAcceleration(300, 0)
    ps:setSpread(1)
    ps:setSizes(5)
    ps:setSpeed(243)
    ps:setColors(1,1,1,1, 1/2,1/2,1,1/2)
    ps:setParticleLifetime(1.5)
    ps:setEmissionRate(243)
    ps:setEmissionArea("borderrectangle", 0, 400, 0)--, true)
    ps:setPosition(-20, 0)
    
    ps:setEmitterLifetime(3)
    -- ps:emit(9)
  else
    print("\""..name.."\" is not a real particle type, dude. giving you \"bash\".")
    return newParticleFoo(y, x, "bash")
  end
  
  -- return p
  
  table.insert(BATTLE.particleSystems, ps)
end

--TODO in your brain: think of different color-change modes, e.g. fading away, cooling off, etc... it might be best to make verbal shortcuts for these things than numerically define dr, dg, db, da for every particle type
--same for size change, i think, and maybe other things! like acceleration (slow down, speed up). velocity can probably stay numeric :)
--TODO math.random for dy and dx is not great. better: choose a random direction and use trigonometry to set dx and dy! that way things will at least spread circularly. I'M A GENIUS (lol no)


--[[
things defined by the PARTICLE TYPE: graphics & quads, colors, sizes, emission area, particle lifetime, spread, direction, speed, accel, damping, rotation, spin, tangential accel, relative rotation, offset, spin & size variations

things defined in the PARTICLE SHAPE: 
- *the particle*
- the *style* of particle system...
  - constant: for weather, field effects, and some status effects
  - timedBursts... just a list of y:x:amount:seconds
  - randomTimedBursts... just amount:seconds; locations are random (within some bounds)
  - movement?
    * funny: "fireball" is not actually a skill you've put in the game. are you sure you need arcing particle emitters? haha
  - bigLine: for quake, tremor, other linear attacks; ideally just define angle + center, then the line will just cut through it at that angle across the whole screen
  - lineFromUserToTarget
  - lineFromUserPastTarget
  - burstAllCellsAtOnce
  - burstAllCellsInRandomOrderFast/Slow
  - directionalBurst: overwrites the particle's normal direction to do a burst
    - could also just do burstLeft, burstRight, etc
  - ...and more!
- position, emitter lifetime & emission rate, emit() bursts and timing, buffer size?

...and so maybe SKILL ANIMATIONS are just sets of type:shape pairs?

for directional math, maybe pre-define N E W S NE NW SE SW? because calculating radians is annoying and confusing

consider using milliseconds for timings. or centiseconds? heh
]]


function newTravelingParticleSystem()
  --fling those fireballs
end