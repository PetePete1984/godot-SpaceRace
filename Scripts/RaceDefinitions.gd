extends Node
var RaceDef = preload("res://Scripts/Model/RaceDef.gd")
var history = preload("res://Scripts/Tools/RaceHistoryParser.gd")
var descriptions = preload("res://Scripts/Tools/RaceDescriptionParser.gd")

# Race Definitions
var races = ["minions"]
var race = {
	"minions": {
		race_name = "Minions",
		race_description = "The %s are a race of robotic beings",
		special_ability = "special_ability_minions"
	}
}

var home_planets = {
	"minions": {
		"size": "enormous",
		"type": "supermineral"
	},
	"snovemdomas": {
		"size": "enormous",
		"type": "primordial"
	},
	"orfa": {
		"size": "large",
		"type": "primordial"
	},
	"orfa": {
		"size": "large",
		"type": "primordial"
	},
	"kambuchka": {
		"size": "enormous",
		"type": "chapel"
	},
	"hanshaks": {
		"size": "large",
		"type": "eden"
	},
	"fludentri": {
		"size": "enormous",
		"type": "congenial"
	},
	"baliflids": {
		"size": "large",
		"type": "special"
	},
	"swaparamans": {
		"size": "large",
		"type": "chapel"
	},
	"frutmaka": {
		"size": "enormous",
		"type": "mineral"
	},
	"shevar": {
		"size": "large",
		"type": "mineral"
	},
	"govorom": {
		"size": "large",
		"type": "cornucopia"
	},
	"ungooma": {
		"size": "large",
		"type": "congenial"
	},
	"dubtaks": {
		"size": "enormous",
		"type": "cathedral"
	},
	"capelons": {
		"size": "enormous",
		"type": "special"
	},
	"mebes": {
		"size": "enormous",
		"type": "tycoon"
	},
	"oculons": {
		"size": "large",
		"type": "cathedral"
	},
	"arbryls": {
		"size": "enormous",
		"type": "eden"
	},
	"marmosians": {
		"size": "large",
		"type": "supermineral"
	},
	"chronomyst": {
		"size": "medium",
		"type": "eden"
	},
	"chamachies": {
		"size": "large",
		"type": "cathedral"
	},
	"nimbuloids": {
		"size": "large",
		"type": "tycoon"
	}
}

func special_ability_minions():
	# on invasion, use one module and succeed
	# TODO: devise a system of hooks into gameplay functions for special abilities
	pass
	
func _ready():
	var race_history = history.read_history()
	var race_descriptions = descriptions.read_descriptions()
	races = race_history.races_in_order
	for r_index in range(races.size()):
		var r = races[r_index]
		var rdef = RaceDef.new()
		var r_hist = race_history.races[r]
		rdef.type = r
		rdef.race_name = r_hist.name
		rdef.race_description = "The %s %s" % [rdef.race_name, race_descriptions[r_index]]
		
		rdef.race_history = {
			"power": r_hist.power,
			"intro": r_hist.intro,
			"text": r_hist.text,
			"peace": r_hist.peace,
			"neutral": r_hist.neutral,
			"hostile": r_hist.hostile
		}
		
		rdef.home_size = home_planets[r].size
		rdef.home_type = home_planets[r].type
		
		rdef.index = r_index
		
		race[r] = rdef
	save_as_json()
	
func save_as_json():
	var racepath = "res://Data/races.json"
	var racefile = File.new()
	racefile.open(racepath, File.WRITE)
	var race_dict = {}
	for k in race.keys():
		race_dict[k] = race[k].race_to_dict()
	racefile.store_string(race_dict.to_json())
	racefile.close()
	