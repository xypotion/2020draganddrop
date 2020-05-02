--or something. might rename this to "spriteMove" or something. doesn't matter right now.

--will cause the contents of g[y][x] to animate through frames
--each frame should contain a pose name, a yOffset, and an xOffset
function spriteMoveEvent(g, x, y, frames)
	local e = {
		class = "spriteMove",
		g = g,
		y = y,
		x = x,
		frames = frames
	}
	
	return e
end

function process_spriteMoveEvent(e)
	local f = pop(e.frames)
	
	-- map[e.y][e.x].contents... --haha, wait. you didn't do it this way yet
	
	
end

-----------------------------------------------------------------------------------------------------------