--similar to gridOps, but for battle

function battleGridOpEvent(command)
  local e = {
    class = "battleGridOp",
    command = command
  }
  
  return e
end

function process_battleGridOpEvent(e)
  print(e.command)
  
  if e.command == "hero remap" then
    mapAllPathsFromHero(BATTLE.grid)
  elseif e.command == "clear target" then
    BATTLE.targetedCell = nil
  else
    print("THERE'S NO SUCH GRID OP AS "..e.command..", LOL")
  end
  
  e.finished = true
end