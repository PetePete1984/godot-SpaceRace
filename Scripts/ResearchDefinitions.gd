extends Node
# Research Definitions
var ResearchDef = preload("res://Scripts/Model/ResearchDef.gd")

var research_defs = {
	"orbital_structures": {
		"position": [12,0,0],
		"cost": 50,
		"index": 0
	},
	"interplanetary_exploration": {
		"position": [-8,2,7],
		"cost": 50,
		"requires": ["orbital_structures"],
		"index": 1
	},
	"tonklin_diary": {
		"position": [2,1,-13],
		"cost": 50,
		"index": 2
	},
	"spacetime_surfing": {
		"position": [5,4,9],
		"cost": 90,
		"requires": ["tonklin_diary", "interplanetary_exploration"],
		"index": 3
	},
	"superconductivity": {
		"position": [-20,3,24],
		"cost": 100,
		"requires": ["tonklin_diary", "xenobiology"],
		"index": 4
	},
	"environmental_encapsulation": {
		"position": [5,2,-30],
		"cost": 50,
		"requires": ["xenobiology"],
		"index": 5
	},
	"xenobiology": {
		"position": [10,0,17],
		"cost": 90,
		"index": 6
	},
	"spectral_analysis": {
		"position": [15,3,-5],
		"cost": 120,
		"requires": ["tonklin_diary"],
		"index": 7
	},
	"advanced_interferometry": {
		"position": [1,5,0],
		"cost": 90,
		"requires": ["spectral_analysis"],
		"index": 8
	},
	"power_conversion": {
		"position": [-24,6,13],
		"cost": 100,
		"requires": ["spacetime_surfing"],
		"index": 9
	},
	"advanced_chemistry": {
		"position": [-17,4,-14],
		"cost": 100,
		"requires": ["environmental_encapsulation"],
		"index": 10
	},
	"momentum_deconservation": {
		"position": [14,7,-16],
		"cost": 140,
		"requires": ["spacetime_surfing"],
		"index": 11
	},
	"gravity_control": {
		"position": [-27,6,-9],
		"cost": 140,
		"requires": ["spacetime_surfing"],
		"index": 12
	},
	"molecular_explosives": {
		"position": [0,8,22],
		"cost": 120,
		"requires": ["spectral_analysis", "power_conversion"],
		"index": 13
	},
	"hyperlogic": {
		"position": [8,7,-9],
		"cost": 140,
		"requires": ["advanced_interferometry", "advanced_chemistry"],
		"index": 14
	},
	"cloaking": {
		"position": [2,6,-15],
		"cost": 180,
		"requires": ["advanced_interferometry"],
		"index": 15
	},
	"gravimetrics": {
		"position": [24,9,-13],
		"cost": 110,
		"requires": ["gravity_control"],
		"index": 16
	},
	"strong_force_weakening": {
		"position": [-8,8,7],
		"cost": 70,
		"requires": ["power_conversion"],
		"index": 17
	},
	"light_bending": {
		"position": [-8,9,7],
		"cost": 160,
		"requires": ["gravity_control"],
		"index": 18
	},
	"advanced_exploration": {
		"position": [-8,12,7],
		"cost": 230,
		"requires": ["mass_phasing", "hyperlogic"],
		"index": 19
	},
	"diplomatics": {
		"position": [-8,8,7],
		"cost": 100,
		"requires": ["hyperlogic"],
		"index": 20
	},
	"mass_phasing": {
		"position": [-8,10,7],
		"cost": 100,
		"requires": ["gravimetrics"],
		"index": 21
	},
	"positron_guidance": {
		"position": [-8,11,7],
		"cost": 100,
		"requires": ["molecular_explosives"],
		"index": 22
	},
	"gravimetric_combustion": {
		"position": [-8,13,7],
		"cost": 100,
		"requires": ["gravimetrics", "positron_guidance"],
		"index": 23
	},
	"em_field_coupling": {
		"position": [-8,10,7],
		"research_name": "EM Field Coupling",
		"cost": 150,
		"requires": ["light_bending"],
		"index": 24
	},
	"subatomics": {
		"position": [-8,12,7],
		"cost": 110,
		"requires": ["positron_guidance"],
		"index": 25
	},
	"planetary_replenishment": {
		"position": [-8,14,7],
		"cost": 80,
		"requires": ["gravimetric_combustion", "environmental_encapsulation"],
		"index": 26
	},
	"momentum_reflection": {
		"position": [-8,15,7],
		"cost": 130,
		"requires": ["subatomics", "momentum_deconservation"],
		"index": 27
	},
	"hyperradiation": {
		"position": [-8,16,7],
		"cost": 140,
		"requires": ["momentum_reflection", "em_field_coupling"],
		"index": 28
	},
	"plasmatics": {
		"position": [-8,14,7],
		"cost": 150,
		"requires": ["subatomics"],
		"index": 29
	},
	"energy_redirection": {
		"position": [-8,18,7],
		"cost": 110,
		"requires": ["hyperradiation"],
		"index": 30
	},
	"large_scale_construction": {
		"position": [-8,15,7],
		"cost": 100,
		"requires": ["gravimetric_combustion", "advanced_exploration"],
		"index": 31
	},
	"level_logic": {
		"position": [-8,9,7],
		"cost": 75,
		"requires": ["hyperlogic"],
		"index": 32
	},
	"star_lane_anatomy": {
		"position": [-8,20,7],
		"cost": 75,
		"requires": ["energy_redirection", "plasmatics"],
		"index": 33
	},
	"stasis_field_science": {
		"position": [-8,19,7],
		"cost": 75,
		"requires": ["hyperradiation"],
		"index": 34
	},
	"coherent_photonics": {
		"position": [-8,21,7],
		"cost": 140,
		"requires": ["energy_redirection"],
		"index": 35
	},
	"superstring_compression": {
		"position": [-8,17,7],
		"cost": 70,
		"requires": ["plasmatics"],
		"index": 36
	},
	"murgatroyd_hypothesis": {
		"position": [-8,18,7],
		"cost": 110,
		"requires": ["superstring_compression", "level_logic"],
		"index": 37
	},
	"matter_duplication": {
		"position": [-8,19,7],
		"cost": 90,
		"requires": ["superstring_compression", "momentum_reflection"],
		"index": 38
	},
	"energy_focusing": {
		"position": [-8,22,7],
		"cost": 90,
		"requires": ["coherent_photonics","murgatroyd_hypothesis"],
		"index": 39
	},
	"scientific_sorcery": {
		"position": [-8,20,7],
		"cost": 90,
		"requires": ["murgatroyd_hypothesis"],
		"index": 40
	},
	"advanced_fun_techniques": {
		"position": [-8,11,7],
		"cost": 90,
		"requires": ["diplomatics"],
		"index": 41
	},
	"repulsion_beam_tech": {
		"position": [-8,24,7],
		"cost": 110,
		"requires": ["energy_focusing"],
		"index": 42
	},
	"hyperwave_technology": {
		"position": [-8,25,7],
		"cost": 110,
		"requires": ["energy_focusing", "hyperradiation"],
		"index": 43
	},
	"fergnatzs_last_theorem": {
		"position": [-8,23,7],
		"research_name": "Fergnatz's Last Theorem",
		"cost": 160,
		"requires": ["scientific_sorcery"],
		"index": 44
	},
	"thought_analysis": {
		"position": [-8,10,7],
		"cost": 110,
		"requires": ["level_logic"],
		"index": 45
	},
	"inertial_control": {
		"position": [-8,22,7],
		"cost": 140,
		"requires": ["star_lane_anatomy", "matter_duplication"],
		"index": 46
	},
	"nanoenergons": {
		"position": [-8,26,7],
		"cost": 170,
		"requires": ["fergnatzs_last_theorem", "hyperwave_technology"],
		"index": 47
	},
	"hypergeometry": {
		"position": [-8,24,7],
		"cost": 170,
		"requires": ["fergnatzs_last_theorem"],
		"index": 48
	},
	"teleinfiltration": {
		"position": [-8,27,7],
		"cost": 110,
		"requires": ["hyperwave_technology", "thought_analysis"],
		"index": 49
	},
	"hyperdrive_technology": {
		"position": [-8,28,7],
		"cost": 110,
		"requires": ["star_lane_anatomy", "teleinfiltration"],
		"index": 50
	},
	"microbotics": {
		"position": [-8,21,7],
		"cost": 110,
		"requires": ["matter_duplication"],
		"index": 51
	},
	"ecosphere_phase_control": {
		"position": [-8,26,7],
		"cost": 110,
		"requires": ["hypergeometry", "planetary_replenishment"],
		"index": 52
	},
	"hyperwave_emission_control": {
		"position": [-8,25,7],
		"cost": 110,
		"requires": ["hyperwave_technology"],
		"index": 53
	},
	"nanopropulsion": {
		"position": [-8,30,7],
		"cost": 200,
		"requires": ["nanoenergons", "hyperwave_technology"],
		"index": 54
	},
	"nanodeflection": {
		"position": [-8,31,7],
		"cost": 240,
		"requires": ["nanofocusing", "inertial_control"],
		"index": 55
	},
	"nanofocusing": {
		"position": [-8,29,7],
		"cost": 240,
		"requires": ["nanoenergons"],
		"index": 56
	},
	"doom_mechanization": {
		"position": [-8,28,7],
		"cost": 400,
		"requires": ["teleinfiltration", "hyperwave_emission_control"],
		"index": 57
	},
	"snooping": {
		"position": [-8,29,7],
		"cost": 120,
		"requires": ["thought_analysis", "hyperwave_emission_control"],
		"index": 58
	},
	"megagraph_theory": {
		"position": [-8,25,7],
		"cost": 120,
		"requires": ["fergnatzs_last_theorem"],
		"index": 59
	},
	"self_modifying_structures": {
		"position": [-8,30,7],
		"cost": 120,
		"requires": ["nanofocusing", "microbotics"],
		"index": 60
	},
	"advanced_planetary_armaments": {
		"position": [-8,23,7],
		"cost": 120,
		"requires": ["coherent_photonics", "murgatroyd_hypothesis"],
		"index": 61
	},
	"accel_energy_replenishment": {
		"position": [-8,32,7],
		"cost": 120,
		"requires": ["megagraph_theory", "nanopropulsion"],
		"index": 62
	},
	"gravity_flow_control": {
		"position": [-8,33,7],
		"cost": 120,
		"requires": ["nanopropulsion"],
		"index": 63
	},
	"action_at_a_distance": {
		"position": [-8,28,7],
		"cost": 120,
		"requires": ["teleinfiltration", "megagraph_theory"],
		"index": 64
	},
	"illusory_machinations": {
		"position": [-8,34,7],
		"cost": 300,
		"requires": ["accel_energy_replenishment", "nanofocusing"],
		"index": 65
	}
}

func _ready():
	var real_defs = {}
	for rkey in research_defs:
		var data = research_defs[rkey]
		var rDef = ResearchDef.new()
		rDef.type = rkey
		for key in data:
			rDef[key] = data[key]
		if rDef.research_name == "":
			rDef.research_name = rkey.capitalize()
		var cost_factor = max(1, (rDef.index-10)*2)
		rDef.cost = rDef.cost * cost_factor
		real_defs[rkey] = rDef
	research_defs = real_defs
	pass