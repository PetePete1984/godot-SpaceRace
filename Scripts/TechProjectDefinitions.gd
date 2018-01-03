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
		"converts": "adjusted_industry",
		"to": "global_diplomacy"
	}, 
	"endless party": {
		"converts": "adjusted_industry",
		"to": "prosperity"
	}, 
	"scientist takeover": {
		"converts": "adjusted_industry",
		"to": "research"
	}, 
	"automation": {
		# TODO: cost == -1 => use the existing project's cost
		"cost": -1,
		"completion_function": "automate_building"
	}, 
	"lush_growth_bomb": {
		"cost": 200,
		# probably won't use this bit
		"provided_pop": 10,
		"completion_function": "growth_bomb_planet"
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