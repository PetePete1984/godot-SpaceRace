# GaneStateHandler is autoloaded
extends Node

signal new_stars_generated(game_state)
signal new_game_prepared

# imports
var GameState = preload("res://Scripts/Model/GameState.gd")
var Player = preload("res://Scripts/Model/Player.gd")
var Colony = preload("res://Scripts/Model/Colony.gd")

var GalaxyGenerator = preload("res://Scripts/GalaxyGenerator.gd")
var RaceGenerator = preload("res://Scripts/RaceGenerator.gd")
var ColonyGenerator = preload("res://Scripts/ColonyGenerator.gd")

# temporary game state for the "new game" screen
var new_game_state

# current game state after loading or starting
# TODO: auto-save after every action
var game_state

# Save stuff
# TODO: saving and loading is responsibility of something else
var saveable_state = {}
var save_path = "user://savegame.sav"

func _ready():
	pass

# this loads the resume savegame or initializes a default game state
func get_most_current_game_state():
	if File.new().file_exists("user://resume.sav"):
		game_state = load_old_game("user://resume.sav")
	else:
		game_state = start_new_game()
	return game_state

# TODO: implement resuming
func load_old_game(path):
	return start_new_game()

# start new default game
# this is also what happens when you resume without a resume state
func start_new_game():
	# TODO: immediately resuming on boot leaves galaxy in a half-finished state
	#randomize()
	game_state = make_game_state(mapdefs.default_galaxy_settings)
	game_state.galaxy = GalaxyGenerator.new().generate_galaxy(null)
	# get a default human player
	var player = RaceGenerator.generate_player(game_state, "minions")
	game_state.races["minions"] = player
	game_state.human_player = player
	
	# plunk the player onto ANY planet
	var random_system = Utils.rand_pick_from_dict(game_state.galaxy.systems)
	var planet = Utils.rand_pick_from_dict(random_system.planets)

	# give the planet a colony base
	var col_gen = ColonyGenerator.new()
	col_gen.initialize_colony(player, planet, true)
	
	return game_state
	pass

# get a default game state, don't assign it to anything
func make_game_state(settings):
	var gs = GameState.new()
	gs.galaxy_settings.galaxy_size = settings.galaxy_size
	gs.galaxy_settings.atmosphere = settings.atmosphere
	gs.galaxy_settings.races = settings.races
	return gs

# this creates a galaxy that can be displayed on the "new game" screen
# and keeps it in new_game_state
func generate_stars(size = null):
	new_game_state = make_game_state(mapdefs.default_galaxy_settings)
	new_game_state.galaxy = GalaxyGenerator.new().generate_stars(size)
	emit_signal("new_stars_generated", new_game_state)
	pass
	
# this takes the existing prepared galaxy (from new_game_state)
# applies the options from the settings screen
# and initializes a proper game state
func initialize_galaxy(galaxy_options, race_key, color):
	if new_game_state:
		# fill temp galaxy with planets
		var gg = GalaxyGenerator.new()
		gg.generate_star_systems(new_game_state.galaxy)
		gg.connect_star_systems(new_game_state.galaxy)
		#print(new_game_state.galaxy.lanes)
		
		# initialize player race
		var player = RaceGenerator.generate_player(new_game_state, race_key)
		player.color = color
		new_game_state.races[race_key] = player
		new_game_state.human_player = player

		# pick & initialize the rest of the races
		var num_races = galaxy_options.races
		var all_races = RaceDefinitions.races
		var other_races = []
		var occupied_systems = []
		while other_races.size() < num_races-1:
			var index = randi() % all_races.size()
			var picked = all_races[index]
			if not picked == race_key and not picked in other_races:
				other_races.append(picked)
		for other_race in other_races:
			var alien = RaceGenerator.generate_player(new_game_state, other_race)
			alien.type = "ai"
			new_game_state.races[other_race] = alien
			
		var col_gen = ColonyGenerator.new()
		for r_key in new_game_state.races:
			var participant = new_game_state.races[r_key]
			# scatter the starter colonies
			# plunk the players onto ANY planet in not yet occupied systems
			var random_system = Utils.rand_key_from_dict(new_game_state.galaxy.systems)
			while random_system in occupied_systems:
				random_system = Utils.rand_key_from_dict(new_game_state.galaxy.systems)

			occupied_systems.append(random_system)
			var random_planet = Utils.rand_key_from_dict(new_game_state.galaxy.systems[random_system].planets)
			var planet = new_game_state.galaxy.systems[random_system].planets[random_planet]

			# give the planet a colony base
			# FIXME: meeeeeeeeh?
			# home = true
			new_game_state.galaxy.systems[random_system].planets[random_planet] = col_gen.initialize_colony(participant, planet, true)
			new_game_state.galaxy.races = new_game_state.races
		
		# move everything into the normal game state
		game_state = null
		game_state = new_game_state
	pass

func save_game_state():
	saveable_state.turn = game_state.turn
	saveable_state.galaxy = game_state.galaxy
	saveable_state.difficulty = game_state.difficulty
	saveable_state.races = game_state.races
	
	var file = File.new()
	if file.open(save_path, File.WRITE) != 0:
		print("Error opening save")
	
	file.store_line(saveable_state.to_json())
	file.close()
	pass

func load_game_state():
	game_state.turn = saveable_state.turn
	game_state.galaxy = saveable_state.galaxy
	game_state.difficulty = saveable_state.difficulty
	game_state.races = saveable_state.races
	pass
