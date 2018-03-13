# Planetary Tech Project Definitions
extends Node

var TechProjectDef = preload("res://Scripts/Model/TechProjectDef.gd")

var project_types = ["alien_hospitality", 
	"endless_party", 
	"scientist_takeover", 
	"automation", 
	"lush_growth_bomb"]
	
var project_defs = {
	"alien_hospitality": {
		"converts_from": "adjusted_industry",
		"converts_to": "diplomacy",
		"requires_research": "diplomatics"
	}, 
	"endless_party": {
		"converts_from": "adjusted_industry",
		"converts_to": "prosperity",
		"requires_research": "advanced_fun_techniques"
	}, 
	"scientist_takeover": {
		"converts_from": "adjusted_industry",
		"converts_to": "research",
		"requires_research": "level_logic"
	}, 
	"automation": {
		# TODO: cost == -1 => use the existing project's cost
		"cost": -1,
		"completion_function": "automate_building",
		"continuous": false,
		"requires_research": "microbotics"
		# TODO: automation uses one extra pop during construction and releases two when done
	}, 
	"lush_growth_bomb": {
		"cost": 200,
		# probably won't use this bit
		"provided_pop": 10,
		"completion_function": "growth_bomb_planet",
		"continuous": false,
		"requires_research": "accel_energy_replenishment"
	}
}

func _ready():
	var real_defs = {}
	for pkey in project_defs:
		var data = project_defs[pkey]
		var pDef = TechProjectDef.new()
		pDef.type = pkey
		for key in data:
			pDef[key] = data[key]
		if pDef.project_name == "":
			pDef.project_name = pkey.capitalize()
		real_defs[pkey] = pDef
	project_defs = real_defs
	pass