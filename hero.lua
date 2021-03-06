--just sort of playing around for now, pretending i know how this will all work. but why not

function initHERO()
  HERO = {}


  --race stuff
  HERO.racialSkills = {1, 2, 3}
  HERO.background = 1


  --portrait and/or sprite
  --DON'T load it at this point, just name it. loading graphics should happen later, behind a loading screen
  HERO.sprite = {
    image = "hero"
  }


  --stats, including affinities
  HERO.baseStats = {
    maxAP = 9,
    ap = 9,
    maxHP = 99,
    hp = 99,
    maxIP = 99,
    ps = 9, --physical strength
    pr = 9, --physical resistance
    es = 9, --elemental strength
    er = 9, --elemental resistance ...these are subject to change, obvs
    level = 0,
    weight = 9,
  }
  HERO.affinities = {
    c = 1,
    p = 1,
    d = 1,
    l = 1,
    s = 1,
    i = 1,
    a = 1,
    v = 1,
    m = 1,
  }


  --hero grid stuff
  HERO.heroGrid = new3x3Grid()

  HERO.heroGridLimits = {
    hearts = 1,
    minds = 1,
    bodies = 1,
    pets = 1,
  }


  --starting grids, etc inventories
  HERO.hearts = {newHeart()}
  HERO.minds = {newMind()}
  HERO.bodies = {newBody()}
  HERO.invocations = {newInvocation()}
  HERO.pets = {newPet()}
  

  --starting card/skill/gear/etc inventories
  HERO.cards = {}
  HERO.skills = {
    loadSkill("fireball"), --oh, right. this works :D
    loadSkill("blizzard") 
  }
  HERO.gear = {
    newGear(1),
    newGear(2),
    newGear(3),
  }
  --TODO makes me think about how customized items will need to be stored in save data. it's pretty much just the attributes, right? otherwise the data is identical & can be re-derived on load?
  
  HERO.keyItems = {}
  HERO.stories = {}
  HERO.recipes = {}
  HERO.toys = {}
  HERO.potions = {}
  HERO.materials = {}


  --put stuff in grids
  -- HERO.bodies[1][2][2].contents = 


  --put grids, etc in hero grid
  HERO.heroGrid[2][2].contents = {type = "heart", id = 1}
  HERO.heroGrid[2][1].contents = {type = "mind", id = 1}
  HERO.heroGrid[2][3].contents = {type = "body", id = 1}
  HERO.heroGrid[1][2].contents = {type = "invocation", id = 1}
  HERO.heroGrid[3][2].contents = {type = "pet", id = 1}

  HERO.activeHeart = 1
  HERO.activeMind = 1
  HERO.activeBody = 1


  --and actually get ready to do stuff
  calculateHEROStats()
end

function newHeart()
  return new3x3Grid()
end

function newMind()
  return new3x3Grid()
end

function newBody()
  return new3x3Grid()
end

function newInvocation()
  return {}
end

function newPet()
  return {}
end

function newGear(id)
  return {id = id}
end


---------------------------------------------------------------------------------------------------


--will be called often; accounts for everything! bonuses from racial skills (?), gear, grid bonuses, key items, etc
function calculateHEROStats()
  HERO.stats = deepClone(HERO.baseStats) --DEBUG
  
  
  --use HERO.baseStats to initialize


  --calculate affinity levels & add to stats


  --factor in current all bonuses from equipped, active grids in hero grid, key items


  --factor in stat bonuses from current body's gear
  
  
  --factor in buffs & debuffs? i guess?

end
--TODO somewhere: a version of this for other units. i think DON'T merge with this function... too much going on with hero; other units are pretty simple by comparison

---------------------------------------------------------------------------------------------------

function getGearEffectsForCommand(command)
  --for each piece of gear in current grid, getEffect(command), then return set TODO
end
--...should this actually search ENTIRE INVENTORY for things you OWN with Attack, Defend, Potion actions?? is that a thing, or no? could just say no... TODO
--...could toss in grids, maybe. so search all four grids (body, mind, heart, hero) ?