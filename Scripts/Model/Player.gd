var race = null

var type = "human" # "ai"

var extinct = false

var colonies = {}
var ships = {}

var research = {}
var completed_research = []

# TODO: reset project on new game
var research_project = null
var buffered_research = 0
var total_research = 0

# initialized from mapdefs colors
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
	# TODO: move this list into research defs
	for i in ["orbital_structures", "interplanetary_exploration", "tonklin_diary", "spacetime_surfing"]:
		if not i in completed_research:
			result = false
			break
	meta_info.space_travel_available = result
	return result
	pass
	
func get_total_research():
	var sum = 0
	for c in colonies:
		var colony = colonies[c]
		sum += colony.adjusted_research
	return sum