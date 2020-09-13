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
  table.insert(particles, newParticle(e.y, e.x, e.params))
  table.insert(particles, newParticle(e.y, e.x, e.params))
  table.insert(particles, newParticle(e.y, e.x, e.params))
  --TODO obviously actually enumerate these in e
  
  e.finished = true
end


---------------------------------------------------------------------------------------------------


--TODO add continuous particle spawner somehow. OK to go in this file i think


---------------------------------------------------------------------------------------------------


--TODO i guess move this elsewhere. it shouldn't go in an event file, probably
--TODO ...and more importantly, there are going to be a ton of different particle types. gotta make data files for that or something. so basically all of this will be scrapped eventually, lol
function newParticle(y, x, name)
  local p = {y = y, x = x, w = 10, h = 10, ttl = 0.25, color = white()}
  
  if name == "bash" then
    -- TODO filename for graphic or something
    
    p.dy = (math.random() - 0.5) * 300
    p.dx = (math.random() - 0.5) * 300
    p.ay = 0 - p.dy
    p.ax = 0 - p.dx
    -- p.dy = p.dy * 4
    -- p.dx = p.dx * 4
  else
    print("that's not a real particle type, dude. giving you \"bash\"")
    return newParticle("bash")
  end
  
  return p
end

--TODO in your brain: think of different color-change modes, e.g. fading away, cooling off, etc... it might be best to make verbal shortcuts for these things than numerically define dr, dg, db, da for every particle type
--same for size change, i think, and maybe other things! like acceleration (slow down, speed up). velocity can probably stay numeric :)
--TODO math.random for dy and dx is not great. better: choose a random direction and use trigonometry to set dx and dy! that way things will at least spread circularly. I'M A GENIUS (lol no)