# Non-Human player Handler
extends Reference

const ColonyManager = preload("res://Scripts/ColonyManager.gd")
const ColonyController = preload("res://Scripts/Controller/ColonyController.gd")
const ResearchManager = preload("res://Scripts/ResearchManager.gd")

static func handle(player):
	for c in player.colonies:
		var colony = player.colonies[c]
		var build_next = ColonyManager.manage(colony)
		if build_next != null:
			if player.race.type == "fludentri":
				printt(build_next, colony.planet.planet_name, player.race.type, GameStateHandler.game_state.turn)
			if build_next.project != null:
				ColonyController.start_colony_project(colony, build_next.project, build_next.type, build_next.square)
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
