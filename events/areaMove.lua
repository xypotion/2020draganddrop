--TODO add a little documentation here...
--also TODO maybe change names? like other events, these are a little vague
function primeAreaMoveEvent(dy, dx, nextArea)
  local e = {
    class = "primeAreaMove",
    nextArea = nextArea,
    dy = dy,
    dx = dx
  }

  return e
end

function process_primeAreaMoveEvent(e)
  PIA = CIA
  PIA.offsetY = 0
  PIA.offsetX = 0

  CIA = e.nextArea
  CIA.offsetY = AREASIZE * cellSize * e.dy
  CIA.offsetX = AREASIZE * cellSize * e.dx

  e.finished = true
end

-----------------------------------------------------------------------------------------------------------

function areaMoveEvent(area, dy, dx)
  local e = {
    class = "areaMove",
    area = area,
    moveFrames = {}
  }

  local maxFrames = 10
  local increment = 0 - cellSize * AREASIZE / maxFrames

  for k = maxFrames - 1, 0, -1 do
    table.insert(e.moveFrames, {
        dy = dy * increment,
        dx = dx * increment
      })
  end

  return e
end

function process_areaMoveEvent(e)
  local frame = pop(e.moveFrames)

  e.area.offsetY = e.area.offsetY + frame.dy
  e.area.offsetX = e.area.offsetX + frame.dx

  if not peek(e.moveFrames) then
    e.finished = true
  end
end