extends Node

onready var EventGenerator = preload("res://Scripts/EventGenerator.gd")
var TurnTimer

signal turn_finished
signal auto_stopped

func _ready():
	TurnTimer = Timer.new()
	#TurnTimer.set_wait_time(0.033)
	TurnTimer.set_wait_time(0.003)
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

# TODO: find a way to have AI do something on the very first turn
# actual gameplay, finally
func game_turn():
	turn_maintenance()
	var game_state = GameStateHandler.game_state
	for race in game_state.races:
		var player = game_state.races[race]
		if not player.extinct:
			# all of the above will have produced notification events, so give these to the players (AI just ignores them)
			if player.type == "human":
				var num_events = EventHandler.count_events(player)
				if num_events > 0:
					auto(false)
					for e in range(num_events):
						var popup = EventHandler.display_event(EventHandler.get_next_event(player))
						# FIXME: this pops up the event on the next screen..
						yield(popup, "event_dismissed")
			
			if player.type == "human":
				# start main player control
				# might try yielding here
				pass
				
			if player.type == "ai":
				# TODO: magic dragons
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
					# no project is running
					# no idle pop
					if colony.get_population().idle == 0:
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
	# FIXME: too late for this
	game_state.turn += 1
	# discard all remaining events
	EventHandler.clear()
	emit_signal("turn_finished")
	pass

# performs all tasks that need to happen before the player gains control
func turn_maintenance():
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
						var labs_before_building = player.meta_info.num_laboratories
						colony.finish_project()

						if labs_before_building == 0 and finished_project == "laboratory":
							if player.count_laboratories() > 0:
								var ev = EventGenerator.generate_research_available(player)
								EventHandler.add_event(player, ev)
						
						if finished_project == "xeno_dig":
							var space_travel_before_project = player.meta_info.space_travel_available
							var random_research = ResearchHandler.finish_random_research(player)
							if space_travel_before_project != player.is_space_travel_available():
								var ev = EventGenerator.generate_space_exploration(player)
								EventHandler.add_event(player, ev)
								# TODO: include event page 2
							var ev = EventGenerator.generate_research_complete(player, random_research)
							EventHandler.add_event(player, ev)

						var ev = EventGenerator.generate_construction(finished_project, colony.planet)
						EventHandler.add_event(player, ev)				
				
				# for all colonies: apply prosperity to upcoming growth
				# unless slots are filled, then halt prosperity
				if colony.planet.population.alive < colony.planet.population.slots:
					colony.remaining_growth -= colony.adjusted_prosperity
					if colony.remaining_growth <= 0:
						# FIXME: don't alert if a project is underway
						var previous_pop = colony.grow_population()
						# FIXME: since this happens after finishing a project, it's wrong
						# Project gets finished, reports "0 free" event, then is cleared
						# following that, this grows the pop and then reports "1 free" - FIRST
						if previous_pop == 0 and colony.planet.population.idle > 0 and colony.project == null:
							var ev = EventGenerator.generate_free_pop(colony.planet)
							EventHandler.add_event(player, ev)
			
			# TODO: maybe refresh this elsewhere
			player.total_research = player.get_total_research()
			
			# apply total research to current research project
			if player.research_project != null:
				player.research_project.remaining_research -= player.total_research + player.buffered_research
				if player.research_project.remaining_research <= 0:
					player.buffered_research = abs(player.research_project.remaining_research)
					var finished_research = player.research_project.research
					var space_travel_before_project = player.meta_info.space_travel_available
					ResearchHandler.finish_research_project(player)
					#player.finish_research_project()
					if space_travel_before_project != player.is_space_travel_available():
						var ev = EventGenerator.generate_space_exploration(player)
						EventHandler.add_event(player, ev)
						# TODO: include event page 2
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