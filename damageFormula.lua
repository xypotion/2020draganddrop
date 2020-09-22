--i picture this saving some confusion later. let's hope!
function damageFormula(name, params)
  print("calculating damage for: "..name)

  --TODO set default values for ALL params to increase chance of success (?)
  
  return pcallIt("df_"..name, params)
end

-- but wait, what is a damage formula supposed to return? just a damage amount, i guess?? 
--TODO maybe rename whole file to "battleFormula", or just "formula", since lots of things will be calculated here, like success rates for non-damage effects

-- what goes into a damage formula?
--[[
  attacker's offensive stats
  target's defensive stats
  attack's potency
  scalers on skills (attributes, grid effects)
  attribute multipliers? for crit rate, i guess
  crit rate & multiplier
  status effects on attacker and target: buffs, debuffs, ailments, field effects
  is the target defending?
  weapon stats if involved
  randomization of damage - built into skill? can do up to 1/27 less unless otherwise specified? maybe 1/9? rollRound, obviously
]]

--what other kinds of formulae are there? ...chance to inflict a thing

function df_attack(p) --basically 100% DEBUG because i don't know what i'm doing yet!
  local damage = 0
  local critMultiplier = 1
  local randomizationMultiplier = 1

  --pcall seems a little unnecessary here...? except yeah, lots of different params for different formulae... ehhh... TODO consider more
  damage = p.user.stats.ps * p.potency / p.target.stats.pr
  
  --is it a critical hit?
  if p.user and p.user.critRate and math.random() < p.user.critRate then
    critMultiplier = 2
    print("crit!")
  end
  
  --randomize damage a bit TODO abstract this for sure
  randomizationMultiplier = 1 - math.random() / 9
  print("rando "..randomizationMultiplier)
  
  --the final math
  damage = rollRound(damage * critMultiplier * randomizationMultiplier)
  print("final damage "..damage)
  
  return damage
end

function df_fireball(p) --basically 100% DEBUG because i don't know what i'm doing yet!
  local damage = 0
  local critMultiplier = 1
  local randomizationMultiplier = 1
  
  damage = p.user.stats.es * p.potency / p.target.stats.er
  
  --is it a critical hit?
  if p.user and p.user.critRate and math.random() < p.user.critRate then
    critMultiplier = 2
    print("crit!")
    --TODO flip a flag or something that changes the animation... or something
  end
  
  --randomize damage a bit TODO abstract this for sure, maybe bundled with the rollRound part
  randomizationMultiplier = 1 - math.random() / 9
  print("rando "..randomizationMultiplier)
  
  --the final math
  damage = rollRound(damage * critMultiplier * randomizationMultiplier)
  print("final damage "..damage)
  
  return damage
end

