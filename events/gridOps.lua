--the intention is for these "grid ops" to be self explanatory
--i.e. look at the "command" parameters. "grid ops" can cover a lot of different things, which is the intent.
--i feel like this is a slightly unhealthy pattern... examine if you ever get more than 10~20 different commands

--TODO maybe rename to overworldGridOps? gridMGMT? gridControl?

function gridOpEvent(g, command, params)
  local e = {
    class = "gridOp",
    g = g,
    command = command,
    params = params
  }

  return e
end

function process_gridOpEvent(e)
  if e.command == "remap" then
    e.g = mapAllPathsFromHero(e.g) --...ok, but it's weird that this works. sigh. pass-by-reference patterns are confusing sometimes
  elseif e.command == "clear obstacles" then --DEBUG
    for y, row in ipairs(e.g) do
      for x, cell in ipairs(row) do
        if cell.contents.class ~= "hero" then
          cell.contents = {class = "clear"}
        end
      end
    end
  elseif e.command == "add obstacles" then --DEBUG junk
    --generate some random obstacles; used to insert "block", "npc", "danger", and "item" randomly after every move :)
    for y, row in ipairs(e.g) do
      for x, cell in ipairs(row) do
        if cell.contents.class == "clear" and math.random() < e.params.threshold then
          local r, g, b = math.random(), math.random(), math.random()

          t = {
            class = e.params.type,
            color = {r, g, b, 1},
            fadeColor = {r, g, b, 0.5},
            message = "my darkness is this strong: "..(1/(r+g+b)),
            yOffset = 0,
            xOffset = 0
          }

          e.g[y][x].contents = t
        end
      end
    end
  else
    print("THERE'S NO SUCH GRID OP AS "..e.command..", LOL")
  end

  e.finished = true
end

-----------------------------------------------------------------------------------------------------------

--don't put other event types in this file. :)