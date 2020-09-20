--[[
this function will turn simple commands into full-on executable battleEvents. this should only be called ONCE per click/tap

data needed in each event set:
- movement
  - move *animation* will be handled in the animation events... i think
  - somehow multi-tile pathed moves will need to be handled in sets of steps. should look/behave the same as on the overworld, except things can happen while walking
    - i think since skills 
- 
- set of animation events, each with:
  - locations
  - animations 
    - particles or other graphics, with their frames; origins & destinations will be wrapped into these if appropriate
  - sound effects
  - flyover damage numbers & effects; these should NOT be in the battlefield canvas... i think. TODO test viability. it all comes down to pixel fonts
  
- TODO more architecture! how will data for skills, weapons, etc be structured?

...for real, maybe go plan this out somewhere else and then come back. loooots of factors in play here


...or just do it here! why not? at least brainstorm

what goes into a skill?
- name, graphic, description(s)... SP cost & attributes
- AP cost, cooldown, warmup
- base attribute(s)
- formula: math, which stats, use weapons or not, relevant effects/attributes (damage mitigation or multiplication)
- added effects: chance of success, variables/stats, 
- animation sequence, including sfx and flying numbers/effects, often multiple stages/hits in sequence (i guess)
- IN MEMORY: cooldown/warmup counter, custom attributes
- these can be equipped to grids or simply referenced by non-player units. ideally no difference between these modes for the skills themselves

what goes into a weapon? or piece of gear, generally? (lots)
- name, graphic, description, shop price
- base attributes
- slot/type, i.e. valid body grid slots
* none of these actions REQUIRE gear, but when they're done, gear can modulate:
  - Attack: AP cost, power, number of hits, accuracy, crit rate & multiplier?, range, extra effects (??)
  - Defend: phys/mag damage reduction, AP holdover increment, extra effects (evasion up, buffs, etc)
  - Potion: potion effect modifiers (base healing change, flat boost, ?), pretty much just extra effects
- IN MEMORY: custom attributes

what goes into a unit? (see hero.lua)
- hp, max hp, main stats, weight
- initiative, i guess
- attributes
- skills

* for all numeric things that are displayed, especially HP and AP, do the actual+displayed thing

what's a status effect?
- base effect loaded from data, then modulated by stats... or something
- still does almost nothing on its own, though. rather, processed by other parts of battle system at key points, which will call out to statuses by name?
  - OR each status will "know" which phase it affects. maybe a series of boolean flags? or just named members of units' effects table
    - e.g. unit.effects["enemyTurnStart"] = {poison, doom} or whatever
    - better: getUnitEffects("enemyTurnStart", unit) -> returns {poison, doom} -> processEffect(unit, poison); (unit, doom)

what's a field effect? 
x i think effectively an ENUM... except no, because a tile can have multiple field effects. 
- so a table of things
- elemental ffx are just strings probably, and they affect the appearance of a tile in a big way
- effects like traps are objects with power levels and such

attribute codes = NUMBERS. i think
x strings that start with E S C U: equipment, skill, card, unit. possibly also G for grid, but i'm probably not doing that anymore
x example: EME for "equipment - metal"
- ...i guess?? there might be a better way. maybe just use numbers
  - 101-118 for units
  - 201-218 for cards
  - 300s for gear, 400s for skills? or something
  - *00 = blank attr? if this is necessary... will probably be handled specially, either way
  * don't forget locked status. separate flag? or part of the number? 
  * what about cursed/damaged? leave room for it in case you decide to add later
]]

function battleEvent(params)
  local e = {
    class = "battle",
    params = params
  }

  --IF this is a favorited skill, treat differently... or that will be handled at a higher level? not sure yet. obviously consider. TODO
  
  return e
end

-- so... all damage formulas and stuff happen BEFORE this event is processed? would kinda make sense & be cleaner. but where should all that happen...
-- ...maybe ^^^ when the event is made? just call to damageFormula(x, y, z) and other things? what about multiple targets & effects? I THINK THAT'S NOT A GOOD PLACE

--happens instantaneously, and is only used for stat & status effect changes
--since other parallel events will need to know & change when various things happen (like animations for variable skills), VERY LITTLE CALCULATION should be done here
--ideally should work for normal battle commands (like Attack), skills, and even the attacks of non-hero units
--animations, actuations, moves all happen elsewhere
function process_battleEvent(e) --TODO i think ultimately rename this. it's too vague
  local t = e.params.target
  local u = e.params.user
    
  t.stats.hp = t.stats.hp - e.params.damage --DEBUG... but only a little :)
  
  u.stats.ap = u.stats.ap - e.params.apCost --DEBUG... ditto :)
  --TODO i'm thinking these should all be separate, single ways of using the event, similar to "gridOps". one "op" at a time
  
  --change scalars, e.g. apply damage to actual HP
  -- for scalar, value in pairs(e.scalarEffects) do
  --   t[scalar].actual = t[scalar].actual + value
  -- end
  
  --add effects to target
  -- for
  
  --remove effects from target
  
  --special: run anonymous functions? use pcall()!
  
  --POSSIBILITY (TODO consider): little floating damage numbers could be spawned (as particles, basically) HERE. will you ever actually want them separated?
  
  e.finished = true
end




--...wow. talk about "muddling through", lol. doing ok so far, though *fingers crossed*