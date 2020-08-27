--[[
example gear table structure:
{
  name, description, 
  graphic,
  shopCost, 
  attributes = {}, --loaded from data AND changed in memory (customization, loading saved customized gear)
  attackEffect = {} or nil,
  defendEffect = {} or nil,
  potionEffect = {} or nil,
  equipEffect = {{}} or nil,
  ownEffect = {{}} or nil
}

this is only for items that can be put in body grids! not potions, key items, crafting items, etc
]]

--load from data.
--used when you are shopping or obtaining treasure
--also used when save data is being loaded? or does this function call THAT function? TODO
function newGear(id)
end

--if battle system calls Attack, Defend, or Potion, does this gear do anything?
function getEffect(command)
  local effect = nil
  
  --actually a pretty simple fetch. this function might not even be necessary? hmm
  
  return effect
end