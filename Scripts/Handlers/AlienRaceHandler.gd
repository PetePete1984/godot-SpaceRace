# Non-Human player Handler
extends Reference

const ColonyManager = preload("res://Scripts/ColonyManager.gd")
const ColonyController = preload("res://Scripts/Controller/ColonyController.gd")
const ResearchManager = preload("res://Scripts/ResearchManager.gd")

static func handle(player):
	# TODO: get global situation, like research completed or in progress (mostly "all", but might have some special cases like "almost done with research campus, don't build labs")
	# also handle potential colony targets, combat, diplomacy actions
	for c in player.colonies:
		var colony = player.colonies[c]
		var build_next = ColonyManager.manage(colony)
		if build_next != null:
			if player.race.type == "fludentri":
				#printt(build_next, colony.planet.planet_name, player.race.type, GameStateHandler.game_state.turn)
				pass
			if build_next.project != null:
				ColonyController.start_project(colony, build_next.square, [build_next.project, build_next.type])
			else:
				#print(build_next)
				pass

	# TODO: evaluate if special ability is useful and optionally use it (also remember for research if chamachie)

	# find available research project if none is running
	# follow some research path
	# pick research
	# do black magic for cheaters, err, chamachies
	if player.total_research > 0:
		var research_next = ResearchManager.manage(player)
		if research_next != null:
			ResearchHandler.start_research(player, research_next)

static func get_player_situation(player):
	# use playerknowledge and diplomacy, also player stats like research, ships and their locations, planet locations, system connections
	var space_travel_available

	var has_shipyards
	var has_orbital_docks

	# list of planets, ordered by industry
	var planets_with_shipyards
	var systems_with_shipyards

	# bool or some sort of list of races
	var is_at_war

	# bool
	var active_special_charged

	# int
	var total_research
	# bool
	var all_research_completed

	# list of races and home planets?
	var visible_races
	var race_relations

	var visible_empty_planets
	# some kind of distance-from-closest-colony-ship-or-shipyard object
	var usable_empty_planets

	# location and number of colonizers
	var colony_ships
	# location and number of invaders
	var invasion_ships
	# location, attack strength, remaining hitpoints
	var combat_ships

	# location, last known info
	var visible_enemy_planets
	# location, defensive strength, ships nearby, other planets defending, distance
	var viable_target_planets

	# location, approximate strength
	var visible_enemy_ships
	# defense and / or hitpoints known and under a threshold
	var defeatable_enemy_ships

	# systems that have ships from a hostile race in them, or <too many> ships from a neutral / friendly race
	var occupied_systems
	var system_with_incoming_ships

	# count colonies
	var num_colonies = player.colonies.keys().size()
	
	# check all colonies' systems; if systems are also colonized by somebody else, they're not controlled
	var num_systems = 0
	var systems = []
	var shared_systems = []
	for c in player.colonies:
		var colony = player.colonies[c]
		var system = colony.planet.system
		var shared_system = false
		if not system in systems:
			for p in system.planets:
				var planet = system.planets[p]
				if planet.colony != null:
					if planet.colony.owner != player:
						shared_system = true
						# short circuit, don't need to check further
						break
			
			# remember controlled systems
			if not shared_system:
				systems.append(system)
			else:
				# also remember contested systems
				shared_systems.append(system)
	
	num_systems = systems.size()
	pass