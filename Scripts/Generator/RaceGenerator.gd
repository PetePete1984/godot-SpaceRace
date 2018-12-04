# Race Generator, instantiates a race as a player

# formal race definition
const RaceDef = preload("res://Scripts/Model/RaceDef.gd")
# an active player
const Player = preload("res://Scripts/Model/Player.gd")

static func generate_player(game_state, race, type = "human"):
	var player = Player.new()
	if game_state.races.has(race):
		print("Race '%s' already in play" % race)
		return null
	
	if race in RaceDefinitions.races:
		var race_def = RaceDefinitions.race[race]
		player.race = race_def
		# TODO: implement special abilities
		#player.race.special_ability = race_def.special_ability
		
	else:
		print("Race not found")
	return player
	pass