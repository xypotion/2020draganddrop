--just sort of playing around for now, pretending i know how this will all work. but why not

function initHERO()
	HERO = {}
	
	
	--race stuff
	HERO.racialSkills = {1, 2, 3}
	HERO.background = 1
	
	
	--portrait and/or sprite
	--DON'T load it at this point, just name it. loading graphics should happen later, behind a loading screen
	HERO.sprite = {
		image = "hero"
	}
	
	
	--stats, including affinities
	HERO.baseStats = {
		maxHP = 99,
		maxIP = 99,
		str = 9,
		def = 9,
		int = 9,
		wis = 9,
		level = 0,
		weight = 9,
	}
	HERO.affinities = {
		c = 1,
		p = 1,
		d = 1,
		l = 1,
		s = 1,
		i = 1,
		a = 1,
		v = 1,
		m = 1,
	}
	HERO.stats = {} --this should be derived (later, i guess) from base + affinities + other other stuff
	
	
	--hero grid stuff
	HERO.heroGrid = new3x3Grid()
	
	HERO.heroGridLimits = {
		hearts = 1,
		minds = 1,
		bodies = 1,
		pets = 1,
	}
	
	
	--starting grids, etc inventories
	HERO.hearts = {newHeart()}
	HERO.minds = {newMind()}
	HERO.bodies = {newBody()}
	HERO.invocations = {newInvocation()}
	HERO.pets = {newPet()}
	
	
	--starting card/skill/gear/etc inventories
	HERO.cards = {}
	HERO.skill = {}
	HERO.gear = {}
	HERO.keyItems = {}
	HERO.stories = {}
	HERO.recipes = {}
	HERO.toys = {}
	HERO.potions = {}
	HERO.crafting = {}
	
	
	--put stuff in grids
	
	
	--put grids, etc in hero grid
	HERO.heroGrid[2][2] = {"heart", 1}
	HERO.heroGrid[2][1] = {"mind", 1}
	HERO.heroGrid[2][3] = {"body", 1}
	HERO.heroGrid[1][2] = {"invocation", 1}
	HERO.heroGrid[3][2] = {"pet", 1}
	
	
	--and actually get ready to do stuff
	calculateHEROStats()
end

function newHeart()
	return new3x3Grid()
end

function newMind()
	return new3x3Grid()
end

function newBody()
	return new3x3Grid()
end

function newInvocation()
	return {}
end

function newPet()
	return {}
end


---------------------------------------------------------------------------------------------------


--will be called often; accounts for everything! racial skills, gear, grid bonuses, etc
function calculateHEROStats()
end

