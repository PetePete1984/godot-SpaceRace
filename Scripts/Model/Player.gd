# the player's race def
var race = null

# the player's AI type (human or ai)
var type = "human" # "ai"

# true if the player has been eliminated
var extinct = false

# set of owned colonies
var colonies = {}
# reference to home colony
var home_colony = null

# list of owned ships
var ships = []

# set of running research
var research = {}
# list of completed research
var completed_research = []
# flag that's set when all research is complete (making research buildings 100% obsolete)
var finished_all_research = false

var research_self_managed = false

# TODO: reset project on new game
var research_project = null
var total_research = 0

# initialized from mapdefs colors
# TODO: might be better to store the color key ("GREEN")
var color = null

var stats = {
	starlane_factor = 1
}

var meta_info = {
	num_laboratories = 0,
	space_travel_available = false
}

var knowledge = null
	
func count_laboratories():
	# FIXME: maybe? count research campus and all other producers? or just ignore the building types, go by total_research > 0 instead?
	var result = 0
	for c in colonies:
		var colony = colonies[c]
		var buildings = colony.planet.buildings
		for x in range(buildings.size()):
			for y in range(buildings[x].size()):
				var building = buildings[x][y]
				if building.type != null:
					if colony.planet.buildings[x][y].type.type == "laboratory":
						result += 1
	# TODO: watch out for this when demolishing buildings
	meta_info.num_laboratories = result
	return result
	
func is_space_travel_available():
	var result = true
	# TODO: move this list into research defs, or game rules
	for i in ["orbital_structures", "interplanetary_exploration", "tonklin_diary", "spacetime_surfing"]:
		if not i in completed_research:
			result = false
			break
	meta_info.space_travel_available = result
	return result
	
func get_total_research():
	var sum = 0
	for c in colonies:
		var colony = colonies[c]
		sum += colony.adjusted_research
	return sum