--TODO it's all kinda messy... probably uppercase all of these, lowercase things like BATTLE and CIA, and add notes about what each of these things is, separate into categories...
--TODO also consider moving some back out, lol. many of these will actually be configurable or set programmatically

cellSize = 128 --72 --uppercase this TODO and maybe change name
overworldZoom = 1 --TODO probably change this to just ZOOM
SCREENCELLSIZE = cellSize * overworldZoom --TODO use this!
HALFSCREENCELLSIZE = SCREENCELLSIZE / 2

ISLANDSIZE = 3
AREASIZE = 5



longPressTime = 0.5


PI = math.pi
TAU = PI * 2


eventFrameLength = 1/81--0.01666



maxFramesForHeroMove = 6


PATHING_DANGER_THRESHOLD = 7
AVOID_HAZARDS = true --TODO make this a configured setting