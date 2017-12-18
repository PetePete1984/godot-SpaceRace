extends Node

onready var EventGenerator = preload("res://Scripts/EventGenerator.gd").new()
var TurnTimer

signal turn_finished
signal auto_stopped

func _ready():
	TurnTimer = Timer.new()
	TurnTimer.set_wait_time(0.033)
	#TurnTimer.set_active(true)
	TurnTimer.set_active(true)
	TurnTimer.connect("timeout", self, "game_turn")
	add_child(TurnTimer)
	pass
	
func auto(enable):
	if enable:
		TurnTimer.start()
	else:
		TurnTimer.stop()
		# TODO: connect signal to button state
		emit_signal("auto_stopped")

# actual gameplay, finally
func game_turn():
	var game_state = GameStateHandler.game_state
	for race in game_state.races:
		var player = game_state.races[race]
		if not player.extinct:
			# for all colonies: apply industry to projects
			for colony_key in player.colonies:
				var colony = player.colonies[colony_key]
				if colony.project != null:
					colony.project.remaining_industry -= colony.adjusted_industry
					if colony.project.remaining_industry <= 0:
						var finished_project = colony.project.building
						colony.finish_project()
						var ev = EventGenerator.generate_construction(finished_project, colony.planet)
						EventHandler.add_event(colony.owner, ev)
				# for all colonies: apply prosperity to upcoming growth
				# unless slots are filled, then halt prosperity
				if colony.planet.population.alive < colony.planet.population.slots:
					colony.remaining_growth -= colony.adjusted_prosperity
					if colony.remaining_growth <= 0:
						# FIXME: don't alert if a project is underway
						var previous_pop = colony.grow_population()
						if (previous_pop == 0 and colony.planet.population.idle > 0):
							var ev = EventGenerator.generate_free_pop(colony.planet)
							EventHandler.add_event(colony.owner, ev)
			
			# TODO: maybe refresh this elsewhere
			player.total_research = player.get_total_research()
			
			# apply total research to current research project
			if player.research_project != null:
				player.research_project.remaining_research -= player.total_research + player.buffered_research
				if player.research_project.remaining_research <= 0:
					player.buffered_research = abs(player.research_project.remaining_research)
					var finished_research = player.research_project.research
					player.finish_research_project()
					var ev = EventGenerator.generate_research_complete(player, finished_research)
					EventHandler.add_event(player, ev)
			else:
				player.buffered_research += player.total_research
			pass
			
			# for all ships in star lanes: move along the lane according to speed & specials (race factor)
			for ship in player.ships:
				if ship.in_starlane():
					ship.move_in_starlane(ship.starlane_speed * player.stats.starlane_factor)
				# TODO: check arrivals and system discoveries
				else:
					# for all ships in systems and orbits: recharge ship energy
					ship.recharge_power()
			
			# all of the above will have produced notification events, so give these to the players (AI just ignores them)
			if player.type == "human":
				var events = EventHandler.get_events(player)
				if events.size() > 0:
					auto(false)
					# FIXME: empty the queue one by one
					for event in events:
						EventHandler.display_event(event)
			
			if player.type == "human":
				# start main player control
				# might try yielding here
				pass
	# if player initiates battle in any battle screen, split that into sub-turns for that system
	#   this is handled outside the normal turn!
	# player is done with control and decides to "next" or "auto"
	#   this might be possible with yield and waiting for a signal
	#	yield( get_tree(), "idle_frame" )
	# collect all notifications and events that result from inaction: planets without projects, ships without orders etc
			for colony_key in player.colonies:
				var colony = player.colonies[colony_key]
				if colony.project == null:
					if colony.get_population().free == 0:
						if GameOptions.events.skip_zero_population == false:
							pass
				pass
			for ship in player.ships:
				pass
	# if player decides to act on those, return to player control
	# otherwise
	# for all ships with unfinished orders: finish orders (movement); ships in auto mode fire on last target or any target in range
	# start AI control in order
	
	# finally, advance turn
	game_state.turn += 1
	# discard all remaining events
	EventHandler.clear()
	emit_signal("turn_finished")
	pass
