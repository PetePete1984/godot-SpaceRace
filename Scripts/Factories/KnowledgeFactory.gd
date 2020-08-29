# Knowledge Factory
# initializes a Player Knowledge state, based on race (special abilities)

const PlayerKnowledge = preload("res://Scripts/Model/PlayerKnowledge.gd")

class Visibility:
	var object
	var visible = false
	var age

static func initialize_player_knowledge(player, game_state):
	# kambuchka: see all home stars, but no communication
	# hanshaks: talk to all races, but no visibility
	# oculons: see all star lanes, but not systems they connect
	var galaxy = game_state.galaxy
	var systems = galaxy.systems
	var lanes = galaxy.lanes
	var races = game_state.races

	# TODO: this prevents having multiples of the same race
	var this_race = player.race
	var race_key = this_race.type

	var see_home_stars = false
	var see_all_races = false
	var see_all_lanes = false

	if race_key == "kambuchka":
		see_home_stars = true
	if race_key == "hanshaks":
		see_all_races = true
	if race_key == "oculons":
		see_all_lanes = true

	var knowledge = PlayerKnowledge.new()

	for system in systems:
		knowledge.systems[system] = false

	# TODO: this currently just stores race keys, might not be enough if there's a need to distinguish between "knows system" and "knows where home planets are"
	for race in races:
		if see_home_stars:
			for colony_key in races[race].colonies:
				var colony = races[race].colonies[colony_key]
				if colony.home:
					knowledge.systems[colony.planet.system] = true
					break
		if see_all_races:
			knowledge.races[race] = true
		else:
			knowledge.races[race] = false

	for lane in lanes:
		if see_all_lanes:
			knowledge.lanes[lane] = true
		else:
			knowledge.lanes[lane] = false

	# TODO: see own race, home system and planet, obviously
	knowledge.races[race_key] = true
	for colony_key in player.colonies:
		var colony = player.colonies[colony_key]
		knowledge.systems[colony.planet.system] = true
		for lane_key in lanes:
			var this_lane = lanes[lane_key]
			if this_lane.connects_to(colony.planet.system):
				knowledge.lanes[lane_key] = true

	player.knowledge = knowledge
