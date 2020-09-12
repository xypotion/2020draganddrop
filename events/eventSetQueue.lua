-- eventsQueue is a table containing eventSets
-- eventSets contain events
-- each event contains a "finished" flag, a class name, and parameters by which it will be processed
-- what else? there must be more to it...

require "events/cellOp"
require "events/gridOps"
require "events/spriteMove"
require "events/areaMove"
require "events/gameState"
require "events/battlePhase"
require "events/battleActionEvent" --TODO change name 9_9
require "events/battleGridOps"

function initEventQueueSystem()
	eventSetQueue = {}
	
	eventFrame = 0
	eventFrameLength = 0.0125 --this is the animation speed for the whole game. could be configurable or at least more formalized somewhere... TODO
	
	currentEvents = {}
end

function queue(event)
	push(eventSetQueue, {event})
end

function queueSet(eventSet)
	push(eventSetQueue, eventSet)
end

-----------------------------------------------------------------------------------------------------------

--TODO clean up. i'm not quite ready to yet...
function eventProcessing(dt)
	eventFrame = eventFrame + dt
	
	--time to process?
	if eventFrame >= eventFrameLength then
		eventFrame = eventFrame % eventFrameLength

		if peek(eventSetQueue) then 
			inputLevel = "none"
		else
			inputLevel = "normal"
			return
		end
		
		local numFinished = 0
		
		-- local es = peek(eventSetQueue)
		-- local numFinished = 0
		if (not currentEvents or empty(currentEvents)) and peek(eventSetQueue) then
			currentEvents = pop(eventSetQueue)
		end
		
		if empty(currentEvents) then print("no current events") end
		
		for k, e in pairs(currentEvents) do --any way of making this work with ipairs()? TODO
			--if not already finished, process this event 
			if not e.finished then
        print("PROCESSING "..e.class.." EVENT") --DEBUG useful
			
				_G["process_"..e.class.."Event"](e)
				
				if e.finished then
          -- print(e.class, " FINISHED") --DEBUG useful
					currentEvents[k] = nil
				end
			end
		end
		
		-- if numFinished == #currentEvents then
		-- 	currentEvents = {}
		-- end
	end
end

--force queue set to be processed immediately, not at next scheduled interval. should start normally again after this
--  ...unfortunately it's not actually NOW, it's at the top of the next update() cycle. 
--  TODO maybe rename and/or make a version that ACTUALLY processes "now", not just "very soon"
--in HDBS this was used only when player input needed to be processed, namely heroMove, heroFight, heroGetPowerup, and heroSpecialAttack
--it will probably be used for more than this
function processNow()
	eventFrame = eventFrameLength
end