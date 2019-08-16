# will contain guidelines for AI ships and/or a way to persist player ship templates
# ideas: have "chunks" of ships and general guidelines instead of exact plans
# chunk "double lane" = 2 star lane drives
# chunk "fill colony" = all open slots shall be colonizers
# chunk "basic_movement" = 1 drive, 1 generator, 1 warp
# chunk "offense" = 1 weapon
# chunk "defense" = 1 shield
# chunk "balanced" = 1 shield, 1 weapon
const chunks = {
	"basic_movement": {
		"tags": {
			"drive": 1, 
			"generator": 1, 
			"lane_drive": 1
		}
	},
	"fill_colony": {
		"modules": {
			"colonizer": -1
		}
	},
	"fill_invader": {
		"modules": {
			"invasion_module": -1
		}
	},
	"repair_support": {
		"modules": {
			"remote_repair_facility": 1,
			"sacrificial_orb": 1
		}
	},
	"immobilizer": {
		"modules": {
			"molecular_tie_down": 1
		}
	},
	"cloak": {
		"modules": {
			"cloaker": 1
		}
	},
	"gate_ship": {
		"modules": {
			"lane_destabilizer": -1
		}
	},
	"kamikaze_ship": {
		"modules": {
			"gravimetric_condensor": 1,
			"nanotwirler": 1,
			"nanowave_space_bender": 1,
			"star_lane_hyperdrive": 1,
			"self_destructotron": 1
		}
	}
}

const prefabs = {
	small_colony = {
		size = "small",
		chunks = ["basic_movement", "fill_colony"],
		bias = "cheapest"
	},
	medium_colony = {
		size = "medium",
		chunks = ["basic_movement", "fill_colony"]
	},
	medium_colony_double_speed = {
		size = "medium",
		chunks = ["basic_movement", "basic_movement", "fill_colony"]
	},
	cheapest_medium_colony = {
		size = "medium",
		chunks = ["basic_movement", "fill_colony"],
		bias = "cheapest"
	},
	large_debug = {
		size = "large",
		chunks = ["basic_movement", "fill_colony"]
	},
	enormous_debug = {
		size = "enormous",
		chunks = ["basic_movement", "fill_colony"]
	}
}