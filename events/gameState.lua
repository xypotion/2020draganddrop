function gameStateEvent(newState)
  local e = {
    class = "gameState",
    newState = newState
  }
  
  return e
end

function process_gameStateEvent(e)
  GAMESTATE = e.newState
  
  e.finished = true
end