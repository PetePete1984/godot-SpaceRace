extends Node

var system_names = []

# star system defs
var system_default_y = 3

var stars = ["blue_giant", "pink-red_giant", "red_giant", "orange_giant", 
			 "blue_medium", "white_medium", "yellow_medium", "light_yellow_medium", "orange_medium", "pink-red_medium",
			 "blue_dwarf", "white_dwarf", "red_dwarf"]

# chances for systems to become specific stars
# TODO: apply star weights when generating galaxy
var star_weights = {
	"blue_giant": 12.57,
	"pink-red_giant": 3.14,
	"red_giant": 5.55,
	"orange_giant": 5.55,
	"blue_medium": 10.35,
	"white_medium": 12.38,
	"yellow_medium": 13.31,
	"light_yellow_medium": 8.50,
	"orange_medium": 4.07,
	"pink-red_medium": 5.73,
	"blue_dwarf": 1.48,
	"white_dwarf": 9.06,
	"red_dwarf": 8.32
}

# average number of starlanes (probably something clever, like int part = number, float part = chance for red)
var average_lanes = {
	"blue_giant": 2.62,
	"pink-red_giant": 2.59,
	"red_giant": 2.57,
	"orange_giant": 2.60,
	"blue_medium": 2.20,
	"white_medium": 2.10,
	"yellow_medium": 2.18,
	"light_yellow_medium": 2.15,
	"orange_medium": 2.05,
	"pink-red_medium": 2.16,
	"blue_dwarf": 1.62,
	"white_dwarf": 2.04,
	"red_dwarf": 2.04
}

# planets per system
var min_planets = 1
var max_planets = 5

# galaxy defs
var default_galaxy_settings = {
	"galaxy_size": "average",
	"atmosphere": "neutral", # "peaceful", "neutral", "hostile"
	"races": 5
}

var galaxy_sizes = ["vacuous", "sparse", "average", "dense", "very_dense"]
var galaxy_size = {
	"vacuous": 16,
	"sparse": 25,
	"average": 60, # seems high
	"dense": 75,
	"very_dense": 86 # unsure, likely 90-100
}

var atmospheres = ["peaceful", "neutral", "hostile"]
var min_races = 3
var max_races = 7
var race_range = range(min_races, max_races+1)

var galaxy_colors = {
	"GREEN": Color8(0,142,69),
	"PURPLE": Color8(130,69,142),
	"YELLOW": Color8(227,190,65),
	"PINK": Color8(219,125,146),
	"BROWN": Color8(121,105,69),
	"BLUE": Color8(36,117,207),
	"ORANGE": Color8(195,97,4),
}
var default_race = "minions"
var default_color = galaxy_colors["GREEN"]

# map defs
# planetmap calculates offsets from planet_max_grid automatically
var planet_max_grid = 11

var planet_sizes = ["tiny", "small", "medium", "large", "enormous"]
var planet_size = {
	"tiny": {
		"map": [[1,1,0],
				[1,1,1],
				[0,1,1]],
		"fields": 7
	},
	"small": {
		"map": [[0,1,0,0,0],
				[1,1,1,0,0],
				[0,1,1,1,0],
				[0,0,1,1,1],
				[0,0,0,1,0]],
		"fields": 11
	},
	"medium": {
		"map": [[0,1,0,0,0,0,0],
				[1,1,1,1,0,0,0],
				[0,1,1,1,1,0,0],
				[0,1,1,1,1,1,0],
				[0,0,1,1,1,1,0],
				[0,0,0,1,1,1,1],
				[0,0,0,0,0,1,0]],
		"fields": 23
	},
	"large": {
		"map": [[0,1,1,0,0,0,0,0,0],
				[1,1,1,1,1,0,0,0,0],
				[1,1,1,1,1,1,0,0,0],
				[0,1,1,1,1,1,1,0,0],
				[0,1,1,1,1,1,1,1,0],
				[0,0,1,1,1,1,1,1,0],
				[0,0,0,1,1,1,1,1,1],
				[0,0,0,0,1,1,1,1,1],
				[0,0,0,0,0,0,1,1,0]],
		"fields": 45
	},
	"enormous": {
		"map": [[0,1,1,1,0,0,0,0,0,0,0],
				[1,1,1,1,1,1,0,0,0,0,0],
				[1,1,1,1,1,1,1,0,0,0,0],
				[1,1,1,1,1,1,1,1,0,0,0],
				[0,1,1,1,1,1,1,1,1,0,0],
				[0,1,1,1,1,1,1,1,1,1,0],
				[0,0,1,1,1,1,1,1,1,1,0],
				[0,0,0,1,1,1,1,1,1,1,1],
				[0,0,0,0,1,1,1,1,1,1,1],
				[0,0,0,0,0,1,1,1,1,1,1],
				[0,0,0,0,0,0,0,1,1,1,0]],
		"fields": 73
	}
}

# order of planet types
var planet_types = [
	"husk",
	"primordial",
	"congenial",
	"eden",
	"mineral",
	"supermineral",
	"chapel",
	"cathedral",
	"special",
	"tycoon",
	"cornucopia"
]

# weighted field color distribution
var planet_type = {
	"husk": {
		"weights": {
			"black": 100,
			"white": 0,
			"red": 0,
			"green": 0,
			"blue": 0
		}
	},
	"primordial": {
		"weights": {
			"black": 50,
			"white": 44,
			"red": 2,
			"green": 2,
			"blue": 2
		}
	},
	"congenial": {
		"weights": {
			"black": 20,
			"white": 69,
			"red": 3,
			"green": 5,
			"blue": 3
		}
	},
	"eden": {
		"weights": {
			"black": 0,
			"white": 74,
			"red": 3,
			"green": 20,
			"blue": 3
		}
	},
	"mineral": {
		"weights": {
			"black": 40,
			"white": 46,
			"red": 10,
			"green": 2,
			"blue": 2
		}
	},
	"supermineral": {
		"weights": {
			"black": 20,
			"white": 56,
			"red": 20,
			"green": 2,
			"blue": 2
		}
	},
	"chapel": {
		"weights": {
			"black": 40,
			"white": 46,
			"red": 2,
			"green": 2,
			"blue": 10
		}
	},
	"cathedral": {
		"weights": {
			"black": 20,
			"white": 54,
			"red": 3,
			"green": 3,
			"blue": 20
		}
	},
	"special": {
		"weights": {
			"black": 40,
			"white": 30,
			"red": 10,
			"green": 10,
			"blue": 10
		}
	},
	"tycoon": {
		"weights": {
			"black": 20,
			"white": 35,
			"red": 15,
			"green": 15,
			"blue": 15
		}
	},
	"cornucopia": {
		"weights": {
			"black": 0,
			"white": 0,
			"red": 33,
			"green": 34,
			"blue": 33
		}
	}
}

# how many pop slots are available on what planet type & size
var planet_slots = {
# tiny, small, medium, large, enormous
# [min, max]
	"husk": [[5,5], [5,5], [5,5], [5,5], [5,5]],
	"primordial": [[5,6], [7,7], [8,10], [13,13], [16,18]],
	"congenial": [[6,7], [7,8], [11,11], [16,16], [24,24]],
	"eden": [[7,7], [8,8], [12,12], [20,20], [29,29]],
	"mineral": [[6,6], [7,8], [8,9], [13,13], [18,21]],
	"supermineral": [[6,7], [8,8], [9,11], [16,17], [23,26]],
	"chapel": [[6,7], [6,8], [8,10], [13,15], [18,18]],
	"cathedral": [[6,7], [7,8], [10,11], [16,18], [22,25]],
	"special": [[5,6], [7,8], [9,10], [13,14], [18,21]],
	"tycoon": [[6,7], [7,8], [11,11], [15,17], [22,25]],
	"cornucopia": [[7,7], [8,8], [12,12], [20,20], [29,29]]
}

# chance for xeno ruins per planet
var planet_xeno_chance = 1.0

# used for tilemap index
var cell_types = ["black", "white", "red", "green", "blue"]
enum CELLS {BLACK, WHITE, RED, GREEN, BLUE}

# FIXME: find references to mapdefs.building_types and replace by BuildingDefinitions.building_types
# used for buildings' tilemap index
#var building_types = ["factory", "agriplot", "laboratory", "habitat", "metroplex",
#	  "colony_base", "industrial_mega_facility", "artificial_hydroponifer", "research_campus",
#	  "logic_factory", "engineer_retreat", "surface_cloaker", "hyperpower_plant", "fertilization_plant",
#	  "internet", "cloning_plant", "observatory", "tractor_beam", "surface_shield", "mega_shield",
#	  "outpost", "transport_tubes", "broken", "terraforming", "xeno_dig", "xeno_ruins"]

func _ready():
	#print("hello, defs")
	var path = "res://Data/star_names.txt"
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		#print("hello, file")
		while not file.eof_reached():
			var line = file.get_line()
			#print(line)
			system_names.append(line)
		file.close()
	else:
		print("can't find star_names.txt")
	#print(system_names.size())
	pass