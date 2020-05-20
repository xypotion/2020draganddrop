--the intention is for these "grid ops" to be self explanatory

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
		GRIDS.debug = mapAllPathsFromHero(GRIDS.debug) --this is definitely wrong
	elseif e.command == "clear obstacles" then
		for y, row in ipairs(e.g) do
			for x, cell in ipairs(row) do
				if cell.contents.class == "obstacle" then
					cell.contents = {class = "clear"}
				end
			end
		end
	elseif e.command == "add obstacles" then
		--generate some random obstacles
		for y, row in ipairs(e.g) do
			for x, cell in ipairs(row) do
				if cell.contents.class == "clear" and math.random() < e.params.threshold then
					local r, g, b = math.random(), math.random(), math.random()
		
					t = {
						class = "obstacle",
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