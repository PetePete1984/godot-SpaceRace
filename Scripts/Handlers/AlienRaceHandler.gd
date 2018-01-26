# Non-Human player Handler
extends Reference

const ColonyManager = preload("res://Scripts/ColonyManager.gd")

static func handle(player):
	for c in player.colonies:
		var colony = player.colonies[c]
		var build_next = ColonyManager.manage(colony)
		if build_next != null:
			if player.race.type == "fludentri":
				print(build_next)
				print(colony.planet.planet_name)
				print(player.race.type)
			ColonyManager.start_colony_project(colony, build_next.project, build_next.type, build_next.square)