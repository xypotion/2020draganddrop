--i picture this saving some confusion later. let's hope!
function damageFormula(name, params)
  print("calculating damage for: "..name)

  if _G["df_"..name] then
    return _G["df_"..name](params)
  end
end

-- _G["process_"..e.class.."Event"](e)

-- but wait, what is a damage formula supposed to return? just a damage amount, i guess??

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
  
  --basic damage calculation
  -- if p.potency and p.user and p.user.ps and p.target and p.target.pr then --TODO try pcall() instead
  --   damage = p.potency * p.user.ps / p.target.pr
  --   print(damage)
  -- end
  --
  local success, error = pcall(function ()
    -- print("anon function??")
      -- tablePrint(p)
    damage = p.user.stats.ps * p.potency / p.target.stats.pr
    -- print("base damage "..damage)
  -- end, function()
    -- return "something went wrong"
    -- return
  end)
  print(error)
  --well, it works, but it ain't elegant. maybe abstract to a try() function? TODO
  
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
  
  --basic damage calculation
  -- if p.potency and p.user and p.user.ps and p.target and p.target.pr then --TODO try pcall() instead
  --   damage = p.potency * p.user.ps / p.target.pr
  --   print(damage)
  -- end
  --
  local success, error = pcall(function ()
    damage = p.user.stats.es * p.potency / p.target.stats.er
  end)
  print(error)
  --well, it works, but it ain't elegant. maybe abstract to a try() function? TODO
  
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

