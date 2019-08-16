extends Node

var BuildingDef = preload("res://Scripts/Model/BuildingDef.gd")

# used for buildings' tilemap index
var building_types = ["factory", "agriplot", "laboratory", "habitat", "metroplex",
	  "colony_base", "industrial_mega_facility", "artificial_hydroponifer", "research_campus",
	  "logic_factory", "engineer_retreat", "surface_cloaker", "hyperpower_plant", "fertilization_plant",
	  "internet", "cloning_plant", "observatory", "tractor_beam", "surface_shield", "surface_mega_shield",
	  "outpost", "transport_tubes", "broken", "terraforming", "xeno_dig", "xeno_ruins"]
#	
#  Flags=special stuff about this item (I'm making some educated guesses here)
#                  0 is used by Automation and Terraforming.
#                  1 means it doesn't consume any population points when you're building it.
#                  2 means its a weapon to be fired at an enemy ship
#                  3 means its a shield (Surface or Orbital)
#				   5 means it'll never run out?
#                  6 means it doesn't use any population points once its built

# colony base is 0
# tractor beam is 2
# weapons are 2
# shields are 3
# outpost is 6
# tubes are 0 and 6
# projects are 1 and 5
# automation, terraforming and xeno dig are 0
# lush growth is 1

# Building definitions
var building_defs = {
	"factory": {
		cost = 30,
		industry = 1
	},
	"agriplot": {
		cost = 30,
		prosperity = 2
	},
	"laboratory": {
		cost = 50,
		research = 1
	},
	"habitat": {
		cost = 160,
		prosperity = 2,
		provided_pop = 3,
		requires_research = "planetary_replenishment"
	},
	"metroplex": {
		cost = 200,
		industry = 1,
		prosperity = 1,
		research = 1,
		provided_pop = 2,
		requires_research = "large_scale_construction"
	},
	"colony_base": {
		industry = 1,
		prosperity = 1,
		provided_pop = 2,
		buildable = false,
		replaceable = false,
		requires_research = "environmental_encapsulation"
	},
	"industrial_mega_facility": {
		cost = 110,
		industry = 3,
		building_name = "Industrial Megafacility",
		requires_research = "positron_guidance"
	},
	"artificial_hydroponifer": {
		cost = 100,
		prosperity = 3,
		requires_research = "advanced_chemistry"
	},
	"research_campus": {
		cost = 160,
		research = 3,
		requires_research = "hyperlogic"
	},
	"logic_factory": {
		cost = 80,
		research = 1,
		prosperity = 1,
		requires_research = "advanced_fun_techniques"
	},
	"engineer_retreat": {
		cost = 80,
		industry = 1,
		research = 1,
		building_name = "Engineering Retreat",
		requires_research = "thought_analysis"
	},
	"surface_cloaker": {
		cost = 40,
		requires_research = "cloaking"
	},
	"hyperpower_plant": {
		cost = 200,
		requires_research = "subatomics"
	},
	"fertilization_plant": {
		cost = 200,
		requires_research = "ecosphere_phase_control"
	},
	"internet": {
		cost = 250,
		requires_research = "megagraph_theory"
	},
	"cloning_plant": {
		cost = 250,
		requires_research = "matter_duplication"
	},
	"observatory": {
		cost = 40,
		building_name = "Observation Installation",
		requires_research = "diplomatics"
	},
	"tractor_beam": {
		cost = 50,
		requires_research = "stasis_field_science"
	},
	"surface_shield": {
		cost = 100,
		requires_research = "superconductivity"
	},
	"surface_mega_shield": {
		cost = 180,
		building_name = "Surface Mega Shield",
		requires_research = "advanced_planetary_armaments"
	},
	"outpost": {
		cost = 120,
		provided_pop = 1
	},
	"transport_tubes": {
		cost = 10,
		used_pop = 0,
		# TODO: tubes need an idle pop to start, but don't use it during building?
		used_pop_during_construction = 0
	},
	"broken": {
		buildable = false
	},
	"terraforming": {
		cost = 50,
		requires_research = "planetary_replenishment"
	},
	"xeno_dig": {
		cost = 50,
		building_name = "Xenoarchaeological Dig",
		requires_research = "xenobiology",
		replaces = ["xeno_ruins"]
	},
	"xeno_ruins": {
		buildable = false,
		used_pop = 0,
		replaced_by = ["xeno_dig"]
	}
}

#var orbital_types = ["shipyard", "missiles", "dock", "cloaker", "shield", "mega_shield", "ship_placeholder", "short_whopper", "long_whopper"]
#var orbital_def = {}

#var planetwide_project_types = ["hospitality", "party", "science", "automation", "growth_bomb"]
#var planetwide_project_def = {}

# TODO: incorporate ships somehow

#var building_def = {
#	"factory", "agriplot", "laboratory", "habitat", "metroplex",
#	"colony_base", "industrial_mega_facility", "artificial_hydroponifer", "research_campus",
#	"logic_factory", "engineer_retreat", "surface_cloaker", "hyperpower_plant", "fertilization_plant",
#	"internet", "cloning_plant", "observatory", "tractor_beam", "surface_shield", "mega_shield",
#	"outpost", "transport_tubes", "broken", "terraforming", "xeno_dig", "xeno_ruins"
#}

var building_restriction = {
	"xeno_dig": "xeno_ruins"
}

# TODO: official mode allows transport tubes everywhere
var cell_restriction = {
	"black": {
		"allowed": [
			"transport_tubes",
			"terraforming"
		]
	}, 
	"white": {
		"restricted": [
			"transport_tubes",
			"terraforming"
		]
	}, 
	"red": {
		"restricted": [
			"transport_tubes",
			"terraforming"
		]
	},
	"green": {
		"restricted": [
			"transport_tubes",
			"terraforming"
		]
	}, 
	"blue": {
		"restricted": [
			"transport_tubes",
			"terraforming"
		]
	}
}

var cell_preference = {
	"black": [
		"terraforming",
		"transport_tubes"
	], 
	"white": ["metroplex"],
	"red": ["industrial_mega_facility", "metroplex", "engineer_retreat", "factory"],
	"green": ["artificial_hydroponifer", "agriplot", "metroplex", "logic_factory"],
	"blue": ["research_campus", "metroplex", "laboratory"]
}

var tile_preference = {
	"industry": "red",
	"research": "blue",
	"prosperity": "green",
	"terraforming": "black",
	"transport_tubes": "black"
}

var building_preference = {
	"industry": ["industrial_mega_facility", "metroplex", "engineer_retreat", "factory"],
	"research": ["research_campus", "metroplex", "laboratory"],
	"prosperity": ["artificial_hydroponifer", "agriplot", "metroplex", "logic_factory"],
	"habitation": ["metroplex", "habitat", "outpost"],
	"weapons_orbital": [],
	"shields_surface": [],
	"shields_orbital": []
}

func _ready():
	var real_defs = {}
	# TODO: maybe use types as index, as in other def files
	for bkey in building_defs:
		var data = building_defs[bkey]
		var bDef = BuildingDef.new()
		bDef.type = bkey
		for key in data:
			bDef[key] = data[key]
		if bDef.building_name == "":
			bDef.building_name = bkey.capitalize()
		real_defs[bkey] = bDef
	building_defs = real_defs
	pass

func get_name(def_key):
	return building_defs[def_key].building_name