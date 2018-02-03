# Orbital Building Definitions
extends Node

var OrbitalDef = preload("res://Scripts/Model/OrbitalDef.gd")

var orbital_types = [
    "shipyard", "missiles", "dock", "cloaker", "shield", "mega_shield", "missiles_dummy", "short_whopper", "long_whopper"
]

var ship_types = ["small", "medium", "large", "enormous"]

var orbital_defs = {
    "shipyard": {
        cost = 240,
        industry = 1,
        requires_research = "orbital_structures"
    },
    "missiles": {
        orbital_name = "Orbital Missile Base",
        cost = 60,
        requires_research = "power_conversion"
    },
    "dock": {
        orbital_name = "Orbital Docks",
        cost = 170,
        industry = 1,
        requires_research = "gravimetrics"
    },
    "cloaker": {
        orbital_name = "Orbital Cloaker",
        cost = 40,
        requires_research = "cloaking"
    },
    "shield": {
        orbital_name = "Orbital Shield",
        cost = 60,
        requires_research = "orbital_structures"
    },
    "mega_shield": {
        cost = 120,
        requires_research = "hyperwave_technology"
    },
    "missiles_dummy": {
        # probably used for ships..
        cost = 20,
        requires_research = "interplanetary_exploration"
    },
    "short_whopper": {
        orbital_name = "Short Range Orbital Whopper",
        cost = 90,
        requires_research = "murgatroyd_hypothesis"
    },
    "long_whopper": {
        orbital_name = "Long Range Orbital Whopper",
        cost = 180,
        requires_research = "advanced_planetary_armaments"
    }
}

func _ready():
	var real_defs = {}
	for orbital_key in orbital_defs:
		var data = orbital_defs[orbital_key]
		var orbital_def = OrbitalDef.new()
		orbital_def.type = orbital_key
		for key in data:
			orbital_def[key] = data[key]
		if orbital_def.orbital_name == "":
			orbital_def.orbital_name = orbital_key.capitalize()
		real_defs[orbital_key] = orbital_def
	orbital_defs = real_defs
	pass