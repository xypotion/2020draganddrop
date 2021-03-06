--data manager... i don't know what this does yet, but i'm pretty sure i'll need it!

function initDataManager()
end


--obviously DEBUG; this will go somewhere else
function loadGraphics()
  IMG = {}
  
  IMG.ditto = love.graphics.newImage("img/ditto.png")
  IMG.meow = love.graphics.newImage("img/meow_knife.png")
  IMG.noidea = love.graphics.newImage("img/no_idea.png")
  IMG.dot = love.graphics.newImage("img/dot.png")
  IMG.calcifer = love.graphics.newImage("img/calcifer.png")
  IMG.ice = love.graphics.newImage("img/ice.png")
  --TODO really, stop copying and pasting this. just write the omni-file-opener vvv
  
  
  --TODO: https://love2d.org/wiki/love.filesystem.getDirectoryItems - the omni-file-opener practically writes itself. more info at https://love2d.org/wiki/love.filesystem
  --TODO: these might be preferable for sprite sheets; investigate: https://love2d.org/wiki/love.graphics.newArrayImage ...it's almost like the art of game design has evolved since the 90s! :o
end






function loadEnemy(member, noVariance)
  local e = loadData("enemy", member)
  
  e.stats.hp = e.stats.maxHP
  
  --TODO stat variance, unless noVariance = true (for whatever reason. boss fight, bestiary...), maybe bosses don't get variance, but common enemies do?
  
  -- tablePrint(e)
  
  return e
end

function loadSkill(member)
  local e = loadData("skill", member)
  
  --?
  -- tablePrint(e)
  e.graphic = IMG[e.graphic]
  
  return e
end

--proof of concept for data-loading stuff
function loadData(dataset, member)
  local obj = deepClone(DATA[dataset].SCHEMA)
  local memberData = split(DATA[dataset][member])

  for k, v in pairs(obj) do
    if type(v) == "number" then
      obj[k] = memberData[v]
      -- print(type(obj[k]))
    elseif type(v) == "table" then
      obj[k] = {}
      for vk, vv in pairs(v) do
        obj[k][vk] = memberData[vv]
        -- print(type(obj[k][vk]))
      end
    end
  end
  
  obj.class = dataset
  
  -- print(obj.stats.ps + obj.stats.pr)
  
  -- tablePrint(obj)
  
  return obj
end


--DEBUG DEBUG DEBUG ain't makin' a butt load of other files for this yet, man. i don't even know what data formats i want yet... (TODO obvs)

DATA = {}

DATA.enemy = { --AI scripts will make this large... except you should probably encapsulate those in another data set :)
  SCHEMA = {name = 1, graphic = 2, stats = {maxHP = 3, ps = 4, pr = 5, es = 6, er = 7, weight = 8, initiative = 9}, attributes = {10, 11, 12, locked = 13}, skillset = 14}, 
  ditto = "Ditto ditto    9999 3 3 3 3  9 1    amorph blank blank 1   ditto",
  --{"a big string with values for all of the above keys... except variable-size arrays like skills don't make sense here :/"},
  meow = {},
}
--[[
speaking of AI... how CAN enemies behave? there are a ton of things to consider
- melee vs. ranged, approach or flee as necessary
- prioritize damaging hero or others
- healing if necessary, buffing when able
- random use of special attacks, or opportunistic (i.e. use if in range)
- use if N targets will be hit, use if hero has a pet or ally summoned
- 100% predetermined, i.e. no a.i. (like rotating laser turrets)
- actual probability testing & strategy checking... ehh... like see what COULD be done, then choose best strategy based on available AP/moves
- avoid hazards (or not) when moving, different hazards types & how they interact with unit attributes
- cross hazards if necessary, or if it's worth it to deal some damage?
- break down barricades if necessary (or not): melee if needed to approach hero, ranged if needed to avoid, UNLESS they would be too hard to break
- moving in line to form syncs, even pushing hero/allies around if necessary
- similar: forming syncs WITH hero/allies, with & without Musk
- probabilities and weighting: consider damage, cost, success chance, critical hit rate, special effects, field effects, target's stats and maybe even other capabilities
- interaction with Light and Dark Light: on an ally, on an enemy, on empty space (basically overrides all normal behavior unless Sentient)
- interaction with other status & field effects
- Sentient enemies should have GOOD AI that tests outcomes and weighs probabilities, i.e. "imagine" N possible turns (slightly randomized), then pick the one that seems best. dmg, etc can be calculated ahead of time
- non-Sentient enemies are more prone to dumb mistakes, like walking into traps, using moves when they can't succeed, etc.; probably they just use basic if-then trees + random choices, and they DON'T use the "imagination" feature
- some randomness in AI is fine. many good RPGs have gotten by with little else :) however, this is a "micro tactics" game, so enemy AI should do what it can
- some enemies Defend
- AP costs

plan: implement in this order...
1. the most basic: enemy can attack once per turn, at range
2. enemy has AP & attacks that many times, spending AP
3. enemy has basic attack and special attack: select one with weighted randomness, considering remaining AP
4. enemy attacks = melee; all of the above, except they will chase you down
5. add a genuine ranged attack + a new *ranged-AI* enemy now; they should move to avoid hero (and allies?)
6. slightly more complex if-thens... heal if needed, move to avoid hazards?, move in for melee hit if possible, otherwise use ranged attack or defend
7. status effect considerations in here somewhere (semi-self awareness)
8. enemies consider summoned allies, not just hero... and allies attack enemies! similar cycle as above if necessary, BUT pet AI should be very similar to enemy AI
9. "sentient" AI & "imagination" system. this will be hard, especially where potential MOVES come in to play
]]

DATA.pets = { --AI scripts will make this large... except you should probably encapsulate those in another data set :)
  debug1 = {},
}

DATA.statusEffects = { --effect name + a FUNCTION for actual effect/behavior + metadata like description, category, when it should be invoked, icon, animation?, class (buff or debuff, etc)
  debug1 = {},
}

DATA.passiveEffects = { --for gear, grids, key items, and other things. i GUESS this is different from status effects?? honestly not sure
  debug1 = {},
}



DATA.enemyAttributes = {
  SCHEMA = {name = 1, abbreviation = 2, debugColor = {3, 4, 5, 6}}, --TODO graphics
  blank = "None _   .2 .2 .2 .2", --TODO in your graphical font, make "_" into another space, i guess? :)
  amorph = "Amorphous AMO   .9 .5 .7 1",
}

DATA.cardAttributes = {
  SCHEMA = {name = 1, abbreviation = 2, debugColor = {3, 4, 5, 6}}, --TODO graphics
  blank = "None _   .2 .2 .2 .2",
  d = "Destruction DES   .95 .1 .1 1",
}

DATA.gearAttributes = {
  SCHEMA = {name = 1, abbreviation = 2, debugColor = {3, 4, 5, 6}}, --TODO graphics
  blank = "None _   .2 .2 .2 .2",
  metal = "Metal MET   .8 .8 .8 1",
}

DATA.skillAttributes = {
  SCHEMA = {name = 1, abbreviation = 2, debugColor = {3, 4, 5, 6}}, --TODO graphics
  blank = "None _   .2 .2 .2 .2",
  d = "Destruction DES   .95 .1 .1 1",
}



DATA.gear = {
  debug1 = {},--boring armor
  debug2 = {},--boring weapon. stick
  debug3 = {},--interesting accessory
}

DATA.skill = { --skills as bought from the skill shop, i.e. the skill's default/germane data. randomization (e.g. of enemy skills when extracted) or variation will be added programatically later
  SEPARATOR = ",",
  SCHEMA = {
    name = 1, graphic = 2, descriptionStrings = {short = 3, medium = 4, long = 5}, 
    attributes = {6, 7, 8, locked = 9}, shopCost = 10, shopMinima = 11,
    animation = 12, method = 13, apCost = 14, cooldown = 15, warmup = 16, range = 17, autoTargetSelector = 18},
  fireball = "Fireball calcifer fireballS fireballM fireballL   d blank blank 1 100 d9   fireball fireball 2 2 0 ranged enemy",
  blizzard = "Blizzard ice blizS blizM blizL   blank blank blank 0 200 s3   blizzard blizzard 3 2 0 ranged enemy",
  debug2 = {}, --maybe a heal or buff
  debug3 = {}, --teleport
}

DATA.cards = {
  debug1 = {},
}

DATA.grids = {
  debug1 = {},
}

DATA.petToys = {
  debug1 = {},
}

DATA.materials = {
  debug1 = {},
}

DATA.recipes = {
  debug1 = {},
}



DATA.particleType = {
  debug1 = {},
}

DATA.particleShape = {
  debug1 = {},
}

DATA.unitAnimations = {
  --graphic TODO, 
  debug1 = {},
}

DATA.screenAnimations = {--particle, density/frequency, direction, overlay
  debug1 = {}, --rain, basically
}



DATA.storyQuests = { --these are actually (probably) big enough that they'll need one file each
  debug1 = {},
}

DATA.genericQuests = { --ditto
  debug1 = {},
}

DATA.cutscenes = { --yikes, another huge one. needs its own scripting engine and stuff. can you use... lua?? *gasp*
  debug1 = {},
}

DATA.npcs = { --for dropping randomly into worlds. pretty much just a graphic and a blurb; anything else ought to be a POI or specifically part of a quest (i.e. if they give you something)
  debug1 = {},
}

DATA.stories = { --sets of quests, basically, with some other stuff (NPC dialogue modifiers?)
  debug1 = {},
}
--hah ha... these stories are different from the "story" key items. need another name for these... super-quests? settings? ehh

DATA.questSettings = {--things like "pasture", "tundra", etc. basically ways of "flavoring" the world
  debug1 = {},
}

DATA.pois = { --not sure about this one, either. "points of interest" (POIs) will usually be a single item. i guess some will be structures/caves, signs, etc... meh
  debug1 = {},
}

DATA.aois = { --more likely to need this than .pois, since "areas of interest" (AOIs) are more interesting, consisting of multiple structures, items, etc
  debug1 = {},
}


DATA.unitPoseSets = { --i guess? many enemies/units will move the same WAYS as each other, i.e. sequences of cells from their sprite sheets. so abstract to common pose sets... i guess
  idle1232 = {},
  idle1234 = {}
}