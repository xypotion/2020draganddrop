--battleData = positions for hero, enemies, obstacles; background color/art, who goes first
--these things will often be randomly generated... should that happen here? or before this event?

function battleStartEvent(battleData)
  local e = {
    class = "battleStart",
    data = battleData,
  }
  
  return e
end

function process_battleStartEvent(e)
  initBattleGrid()  

  if e. data and e.data.gridContents then
    for k, cell in pairs(e.data.gridContents) do
      -- tablePrint(cell)
      BATTLE.grid[cell.y][cell.x].contents = cell.contents
    end
  end
  
  -- print("did it")
  
  e.finished = true
end

-----------------------------------------------------------------------------------------------------------

function battleEndEvent()
  local e = {}
  
  return e
end

function process_battleEndEvent()
end

-----------------------------------------------------------------------------------------------------------

--