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

--TODO move this somewhere, probably a new file
function battleCommand_heroAttack()
  print("heroAttack time!")
  
  if not BATTLE.targetedCell then
    print("...no target, dummy")
    return
    --TODO obviously auto-target something
  end
  
  print("ping")
  
  --calculate damage
  local damage = damageFormula("attack", {user = HERO, target = getBattleTargetCell().contents, potency = 100})
  
  --queue events: damage, animation; hp actuation
  queueSet({
    battleEvent({
      user = HERO, 
      target = getBattleTargetCell().contents, 
      damage = damage, 
      apCost = 1
    }),
    particleEvent(100, 100, "bash") --TODO obvs put on target
  })
end

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