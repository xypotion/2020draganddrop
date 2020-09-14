--data manager... i don't know what this does yet, but i'm pretty sure i'll need it!

function initDataManager()
end

function loadData(thing)
end



--DEBUG DEBUG DEBUG ain't makin' a butt load of other files for this yet, man. i don't even know what data formats i want yet... (TODO obvs)

DATA = {}

DATA.enemies = { --AI scripts will make this large... except you should probably encapsulate those in another data set :)
  debug1 = {},
}

DATA.statusFX = { --effect name + a FUNCTION for actual effect/behavior + metadata like description, category, when it should be invoked, icon, animation?, class (buff or debuff, etc)
  debug1 = {},
}

DATA.gear = {
  debug1 = {},--boring armor
  debug2 = {},--boring weapon. stick
  debug3 = {},--interesting accessory
}

DATA.skills = {
  debug1 = {}, --fireball, what else?
}

DATA.cards = {
  debug1 = {},
}

DATA.grids = {
  debug1 = {},
}

DATA.attributes = { --? not sure about this one. used for items, units, cards, skills... but not sure if necessary
  debug1 = {},
}

DATA.passiveEffects = { --for gear, grids, key items, and other things. i GUESS this is different from status effects?? honestly not sure
  debug1 = {},
}



DATA.unitAnimations = {
  debug1 = {},
}

DATA.screenAnimations = {--particle, density/frequency, direction, overlay
  debug1 = {}, --rain, basically
}

DATA.particles = {
  debug1 = {},
}

DATA.quests = { --these are actually (probably) big enough that they'll need one file each
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