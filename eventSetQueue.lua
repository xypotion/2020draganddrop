-- eventsQueue is a table containing eventSets
-- eventSets contain events
-- each event contains a "finished" flag, a class name, and parameters by which it will be processed
-- what else? there must be more to it...

require "events/cellOp"
require "events/gridOps"
require "events/spriteMove"

function initEventQueueSystem()
	eventSetQueue = {}
	
	eventFrame = 0
	eventFrameLength = 0.05
	
	currentEvents = {}
end

function queue(event)
	push(eventSetQueue, {event})
end

function queueSet(eventSet)
	push(eventSetQueue, eventSet)
end

-----------------------------------------------------------------------------------------------------------

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
		
		for k, e in pairs(currentEvents) do
		-- for k, e in pairs(currentEvents) do --TODO figure out why this breaks it. it should work BETTER, but it doesn't.
			--if not already finished, process this event 
			if not e.finished then
				-- print("processing "..e.class)
			
				-- if e.class == "function" then --i kind of want to avoid doing this again
				-- 	-- print("...calling "..e.func)
				-- 	_G[e.func](e.arg1)
				-- 	e.finished = true?
				-- else
					_G["process_"..e.class.."Event"](e)
				-- end
				
				if e.finished then
					currentEvents[k] = nil
					-- print("something")
					-- numFinished = numFinished + 1
				end
			end
		end
		
		-- if numFinished == #currentEvents then
		-- 	currentEvents = {}
		-- end
	end
end

--force queue set to be processed immediately, not at next scheduled interval. should start normally again after this
--in HDBS this was used only when player input needed to be processed, namely heroMove, heroFight, heroGetPowerup, and heroSpecialAttack
--it will probably be used for more than this
function processNow()
	eventFrame = eventFrameLength
end