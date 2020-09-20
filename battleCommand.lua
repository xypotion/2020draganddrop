--[[
  this is actually a pretty good flow for battle logic, i think...
1. register click, and find command in grid if present
2. battleLogic's battleClick() calls command as a function; for MAIN COMMANDS, this is totally fine & makes sense
3. that function does all damage & effect calculation, then queues up events; NO STATE CHANGE THAT'S NOT EVENT-BASED
4. events simply resolve effects and animate
...this should work for pretty much any main command

for skills and grid switches, command should be "skill" or "grid", with a sub-parameter
battleClick actually just always passes the commandParams, which is a table containing skill or grid data

]]


function battleCommand(cmd, params)
  local bc = "battleCommand_"..cmd
  local success, error = pcall(_G[bc], params)
  
  if error and not success then
    print("tried to run "..bc..", but this happened:\n"..error)
    if error == "attempt to call a nil value" then 
      print("("..bc.." probably isn't defined, dummy)") 
    end
  end
  
  return success, error --probably not necessary, but what the heck
end

-----------------------------------------------------------------------------------------------------------

--when Attack is clicked
function battleCommand_heroAttack()
  print("heroAttack time!")
  
  if not BATTLE.targetedCell then
    print("...no target, dummy")
    return
    --TODO obviously auto-target something
  end
  
  print("ping")
  
  --calculate damage
  local ty, tx = BATTLE.targetedCell.y, BATTLE.targetedCell.x
  local tc = BATTLE.grid[ty][tx]
  local damage = damageFormula("attack", {user = HERO, target = tc.contents, potency = 100})
  
  --queue events: damage, animation; hp actuation
  queueSet({
    battleEvent({
      user = HERO, 
      target = tc.contents, 
      damage = damage, 
      apCost = 1
    }),
    particleEvent(ty * cellSize * overworldZoom + HALFCELLSIZE, tx * cellSize * overworldZoom + HALFCELLSIZE, "bash"),
    --TODO sound effect!
  })
end

--when Move is clicked; only works if some cell is targeted
--TODO Move/Push is still a thing, right? one command that changes based on what you're targeting? Push should show success chance if so
function battleCommand_heroMove(test)
  if test then
    -- tablePrint(test)
    print(test)
  end
  
  --TODO check for other things... what's actually in the targeted cell (it doesn't actually have to be "clear")? it's not where you already are, right? etc
  if BATTLE.targetedCell then
    local tCell = BATTLE.grid[BATTLE.targetedCell.y][BATTLE.targetedCell.x]
    local starty = findHeroLocationInGrid(BATTLE.grid)
    
    if tCell.pathFromHero[1] and tCell.contents.class == "clear" then --can we actually go there?
      queue(battleGridOpEvent("clear target"))
      
      for k, step in ipairs(tCell.pathFromHero) do
        print("step:", step.y, step.x)
        moveBattleUnitAtYX(starty.y, starty.x, step.y - starty.y, step.x - starty.x)
        --TODO decrement AP
        --TODO interact with field effects

        starty = step
      end
      
      --TODO actual sprite animations? including poses & directions
      --TODO turn hero back south ("towards camera") after walk is done
      
      queue(battleGridOpEvent("hero remap")) --it's really perplexing that WITHOUT this, movement doesn't complete. why would that be?? TODO should really figure this out... it hints at deeper problem
      
      processNow()
    end
  end
end

--TODO this was *copied* from overworldLogic; DRY it up!
function moveBattleUnitAtYX(y, x, dy, dx, max)
  local ty, tx = y + dy, x + dx --t as in "target"

  --max = the number of movement frames it'll take this movement to finish
  max = max or maxFramesForHeroMove

  local moveFrames = {}

  for k = max - 1, 0, -1 do
    push(moveFrames, {
        pose = "idle", 
        yOffset = dy * -(cellSize * k / max), 
        xOffset = dx * -(cellSize * k / max)
      })
  end

  --queue pose and cell ops
  queueSet({
      cellSwapEvent(BATTLE.grid, y, x, ty, tx), --eventually swapping won't work, but ok for now. DEBUG
      spriteMoveEvent(BATTLE.grid, ty, tx, moveFrames)
    })

  -- processNow()
end


-----------------------------------------------------------------------------------------------------------

function battleCommand_heroUseSkill(id)
  local s = HERO.skills[id]
  
  -- tablePrint(s)
  
  if not BATTLE.targetedCell then
    autoTarget(s.autoTargetSelector)
  end

  local ty, tx = BATTLE.targetedCell.y, BATTLE.targetedCell.x
  local tc = BATTLE.grid[ty][tx]
  
  --call the thing
  local method = "skill_"..s.method
  local success, error = pcall(_G[method], {user = HERO, target = tc.contents, skill = s})
  
  if error and not success then
    print("tried to run "..method..", but this happened:\n"..error)
    
    if error == "attempt to call a nil value" then 
      print("("..method.." probably isn't defined, dummy)") 
    end
  end
  
  -- if success then
    --apply effects now?
end

function autoTarget(type) --TODO DEBUG ETC this is not final
  --find an enemy to target. DEBUG doesn't matter which :P
  print("AUTO TARGETING")
  
  for k, v in pairs(allCellsInGrid(BATTLE.grid)) do
    if v.cell.contents and v.cell.contents.class == "enemy" then
      setBattleTargetedCell(v.x, v.y)
    end
  end
end

function skill_fireball(params)
  --[[
  what actually happens at this point for a typical skill?
  1. determine variant, if applicable; some 
  2. determine targets (there might be multiple); this might even be empty tiles, not combatants!
  3. tally total scaling factor
  4. check targets' attributes to see if there's any special logic, e.g. an auto-crit
  5. determine effects via (usually?) external formulae: damage, status changes, field effects... calculations will often include the scale factor
  6. queue events to resolve effects, including: sound, animations, damage numbers, movement, unit death, ...
  
  the holy grail here is to use these same functions for when enemies use these skills (rather than making separate versions for each skill)
  ]]
        
  local ty, tx = BATTLE.targetedCell.y, BATTLE.targetedCell.x --find a better way. TODO (actually yeah, this totally doesn't work when enemies use skill)
  local tc = BATTLE.grid[ty][tx]
  params.potency = 500
  local damage = damageFormula("fireball", params)
  
  --queue events: damage, animation; hp actuation
  queueSet({
    battleEvent({
      user = HERO, 
      target = tc.contents, 
      damage = damage, 
      apCost = 2
    }),
    particleEvent(ty * cellSize * overworldZoom + HALFCELLSIZE, tx * cellSize * overworldZoom + HALFCELLSIZE, "fireball"),
  })
end