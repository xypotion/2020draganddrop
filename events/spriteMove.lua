--will cause the contents of g[y][x] to animate through frames
--each frame should contain a pose name, a yOffset, and an xOffset
function spriteMoveEvent(g, y, x, frames)
	local e = {
		class = "spriteMove",
		g = g,
		y = y,
		x = x,
		frames = frames
	}
	
	return e
end

--copied basically wholesale from HDBS' poseEvent processor :)
function process_spriteMoveEvent(e)
	local f = pop(e.frames)
	
	e.g[e.y][e.x].contents.pose = f.pose
	e.g[e.y][e.x].contents.yOffset = f.yOffset
	e.g[e.y][e.x].contents.xOffset = f.xOffset
	
	if not peek(e.frames) then
		e.finished = true
	end
end

-----------------------------------------------------------------------------------------------------------