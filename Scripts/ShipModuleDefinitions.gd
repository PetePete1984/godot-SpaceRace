extends Node

var ShipModuleDef = preload("res://Scripts/Model/ShipModuleDef.gd")

var ship_module_categories = ["weapon", "shield", "drive", "scanner", "generator", "special"]

var ship_module_types = [
	"empty_module",
	"mass_barrage_gun",
	"fourier_missiles",
	"quantum_singularity_launcher",
	"molecular_disassociator",
	"electromagnetic_pulser",
	"plasmatron",
	"ueberlaser",
	"fergnatz_lens",
	"hypersphere_driver",
	"nanomanipulator",
	"ion_wrap",
	"concussion_shield",
	"wave_scatterer",
	"deactotron",
	"hyperwave_nullifier",
	"nanoshell",
	"tonklin_motor",
	"ion_banger",
	"graviton_projector",
	"inertia_negator",
	"nanowave_space_bender",
	"tonklin_frequency_analyzer",
	"subspace_phase_array",
	"aural_cloud_constructor",
	"hyperwave_tympanum",
	"murgatroyds_knower",
	"nanowave_decoupling_net",
	"proton_shaver",
	"subatomic_scoop",
	"quark_express",
	"van_creeg_hypersplicer",
	"nanotwirler",
	"lane_blocker",
	"molecular_tie_down",
	"intellect_scrambler",
	"brunswik_dissipator",
	"recaller",
	"disarmer",
	"smart_bomb",
	"gravity_distorter",
	"fleet_disperser",
	"x_ray_megaglasses",
	"cloaker",
	"star_lane_drive",
	"star_lane_hyperdrive",
	"positron_bouncer",
	"gravimetric_catapult",
	"myrmidonic_carbonizer",
	"containment_device",
	"shield_blaster",
	"backfirer",
	"lane_destabilizer",
	"tractor_beam",
	"cannibalizer",
	"moving_part_exploiter",
	"hyperswapper",
	"gravimetric_condensor",
	"accutron",
	"remote_repair_facility",
	"sacrificial_orb",
	"lane_magnetron",
	"disintegrator",
	"lane_endoscope",
	"toroidal_blaster",
	"gizmogrifier",
	"replenisher",
	"specialty_blaster",
	"gyro_inductor",
	"plasma_coupler",
	"invulnerablizer",
	"phase_bomb",
	"colonizer",
	"self_destructotron",
	"invasion_module",
	"mass_condensor",
	"hyperfuel"
]

# TODO: test and rethink the empty module
var ship_module_defs = {
	"empty_module": {
		"index": 0
	},
	"mass_barrage_gun": {
		"category": "weapon",
		"requires_research": "superconductivity"
	},
	"fourier_missiles": {
		"category": "weapon",
		"requires_research": "spectral_analysis"
	},
	"quantum_singularity_launcher": {
		"category": "weapon",
		"requires_research": "gravity_control"
	},
	"molecular_disassociator": {
		"category": "weapon",
		"requires_research": "strong_force_weakening"
	},
	"electromagnetic_pulser": {
		"category": "weapon",
		"requires_research": "em_field_coupling"
	},
	"plasmatron": {
		"category": "weapon",
		"requires_research": "plasmatics"
	},
	"ueberlaser": {
		"category": "weapon",
		"requires_research": "coherent_photonics"
	},
	"fergnatz_lens": {
		"category": "weapon",
		"requires_research": "fergnatzs_last_theorem"
	},
	"hypersphere_driver": {
		"category": "weapon",
		"requires_research": "hypergeometry"
	},
	"nanomanipulator": {
		"category": "weapon",
		"requires_research": "nanofocusing"
	},
	"ion_wrap": {
		"category": "shield",
		"requires_research": "environmental_encapsulation"
	},
	"concussion_shield": {
		"category": "shield",
		"requires_research": "momentum_deconservation"
	},
	"wave_scatterer": {
		"category": "shield",
		"requires_research": "light_bending"
	},
	"deactotron": {
		"category": "shield",
		"requires_research": "energy_redirection"
	},
	"hyperwave_nullifier": {
		"category": "shield",
		"requires_research": "hyperwave_technology"
	},
	"nanoshell": {
		"category": "shield",
		"requires_research": "nanodeflection"
	},
	"tonklin_motor": {
		"category": "drive",
		"requires_research": "tonklin_diary"
	},
	"ion_banger": {
		"category": "drive",
		"requires_research": "advanced_chemistry"
	},
	"graviton_projector": {
		"category": "drive",
		"requires_research": "gravimetric_combustion"
	},
	"inertia_negator": {
		"category": "drive",
		"requires_research": "inertial_control"
	},
	"nanowave_space_bender": {
		"category": "drive",
		"requires_research": "nanopropulsion"
	},
	"tonklin_frequency_analyzer": {
		"category": "scanner",
		"requires_research": "tonklin_diary"
	},
	"subspace_phase_array": {
		"category": "scanner",
		"requires_research": "advanced_interferometry"
	},
	"aural_cloud_constructor": {
		"category": "scanner",
		"requires_research": "em_field_coupling"
	},
	"hyperwave_tympanum": {
		"category": "scanner",
		"requires_research": "hyperradiation"
	},
	"murgatroyds_knower": {
		"ship_module_name": "Murgatroyd's Knower",
		"category": "scanner",
		"requires_research": "murgatroyd_hypothesis"
	},
	"nanowave_decoupling_net": {
		"category": "scanner",
		"requires_research": "nanoenergons"
	},
	"proton_shaver": {
		"category": "generator",
		"requires_research": "interplanetary_exploration"
	},
	"subatomic_scoop": {
		"category": "generator",
		"requires_research": "power_conversion"
	},
	"quark_express": {
		"category": "generator",
		"requires_research": "subatomics"
	},
	"van_creeg_hypersplicer": {
		"category": "generator",
		"requires_research": "hyperradiation"
	},
	"nanotwirler": {
		"category": "generator",
		"requires_research": "nanoenergons"
	},
	"lane_blocker": {
		"category": "special",
		"requires_research": "star_lane_anatomy"
	},
	"molecular_tie_down": {
		"category": "special",
		"requires_research": "gravimetrics"
	},
	"intellect_scrambler": {
		"category": "special",
		"requires_research": "hyperlogic"
	},
	"brunswik_dissipator": {
		"category": "special",
		"requires_research": "stasis_field_science"
	},
	"recaller": {
		"category": "special",
		"requires_research": "energy_redirection"
	},
	"disarmer": {
		"category": "special",
		"requires_research": "matter_duplication"
	},
	"smart_bomb": {
		"category": "special",
		"requires_research": "scientific_sorcery"
	},
	"gravity_distorter": {
		"category": "special",
		"requires_research": "momentum_reflection"
	},
	"fleet_disperser": {
		"category": "special",
		"requires_research": "repulsion_beam_tech"
	},
	"x_ray_megaglasses": {
		"ship_module_name": "X-Ray Megaglasses",
		"category": "special",
		"requires_research": "hyperlogic"
	},
	"cloaker": {
		"category": "special",
		"requires_research": "cloaking"
	},
	"star_lane_drive": {
		"category": "special",
		"requires_research": "spacetime_surfing"
	},
	"star_lane_hyperdrive": {
		"category": "special",
		"requires_research": "advanced_exploration"
	},
	"positron_bouncer": {
		"category": "special",
		"requires_research": "positron_guidance"
	},
	"gravimetric_catapult": {
		"category": "special",
		"requires_research": "mass_phasing"
	},
	"myrmidonic_carbonizer": {
		"category": "special",
		"requires_research": "energy_focusing"
	},
	"containment_device": {
		"category": "special",
		"requires_research": "scientific_sorcery"
	},
	"shield_blaster": {
		"category": "special",
		"requires_research": "teleinfiltration"
	},
	"backfirer": {
		"category": "special",
		"requires_research": "hyperwave_emission_control"
	},
	"lane_destabilizer": {
		"category": "special",
		"requires_research": "star_lane_anatomy"
	},
	"tractor_beam": {
		"category": "special",
		"requires_research": "stasis_field_science"
	},
	"cannibalizer": {
		"category": "special",
		"requires_research": "coherent_photonics"
	},
	"moving_part_exploiter": {
		"category": "special",
		"requires_research": "action_at_a_distance"
	},
	"hyperswapper": {
		"category": "special",
		"requires_research": "hypergeometry"
	},
	"gravimetric_condensor": {
		"category": "special",
		"requires_research": "gravity_flow_control"
	},
	"accutron": {
		"category": "special",
		"requires_research": "energy_focusing"
	},
	"remote_repair_facility": {
		"category": "special",
		"requires_research": "self_modifying_structures"
	},
	"sacrificial_orb": {
		"category": "special",
		"requires_research": "energy_redirection"
	},
	"lane_magnetron": {
		"category": "special",
		"requires_research": "hyperdrive_technology"
	},
	"disintegrator": {
		"category": "special",
		"requires_research": "doom_mechanization"
	},
	"lane_endoscope": {
		"category": "special",
		"requires_research": "snooping"
	},
	"toroidal_blaster": {
		"category": "special",
		"requires_research": "gravimetric_combustion"
	},
	"gizmogrifier": {
		"category": "special",
		"requires_research": "fergnatzs_last_theorem"
	},
	"replenisher": {
		"category": "special",
		"requires_research": "light_bending"
	},
	"specialty_blaster": {
		"category": "special",
		"requires_research": "teleinfiltration"
	},
	"gyro_inductor": {
		"category": "special",
		"requires_research": "murgatroyd_hypothesis"
	},
	"plasma_coupler": {
		"category": "special",
		"requires_research": "plasmatics"
	},
	"invulnerablizer": {
		"category": "special",
		"requires_research": "illusory_machinations"
	},
	"phase_bomb": {
		"category": "special",
		"requires_research": "molecular_explosives"
	},
	"colonizer": {
		"category": "special",
		"requires_research": "environmental_encapsulation"
	},
	"self_destructotron": {
		"category": "special",
		"requires_research": "doom_mechanization"
	},
	"invasion_module": {
		"category": "special",
		"requires_research": "advanced_interferometry"
	},
	"mass_condensor": {
		"category": "special",
		"requires_research": "molecular_explosives"
	},
	"hyperfuel": {
		"category": "special",
		"requires_research": "superstring_compression"
	}
}

func _ready():
	var real_defs = {}
	var index = 0
	for key in ship_module_types:
		var data = ship_module_defs[key]
		var def = ShipModuleDef.new()
		def.type = key
		def.index = index
		index += 1
		for data_key in data:
			def[data_key] = data[data_key]
		if def.ship_module_name == "":
			def.ship_module_name = key.capitalize()
		real_defs[key] = def
	ship_module_defs = real_defs