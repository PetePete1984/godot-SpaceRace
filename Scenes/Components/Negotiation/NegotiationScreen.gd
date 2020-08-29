extends "res://Scripts/Model/Screen.gd"

func _ready():
	pass

func set_player(player):
	pass

func set_payload(payload):
	set_up_negotiation(payload)

func set_up_negotiation(negotiation_data):
	debug_diplomacy_info(negotiation_data)
	pass

func parse_diplomacy_message(message, me = null, you = null, them = null, system = null):
	var message_data = {}
	var result = message
	if me:
		message_data["%m"] = me.race.race_name
	if you:
		message_data["%y"] = you.race.race_name
	if them:
		message_data["%t"] = them.race.race_name
	if system:
		message_data["%s"] = system.system_name
	for key in message_data:
		result = result.replace(key, message_data[key])

	return result

func debug_diplomacy_info(negotiation_data):
	var state = GameStateHandler.game_state
	var you = state.human_player

	var me_key = state.races.keys()[1]
	var me = state.races[me_key]

	var them_key = state.races.keys()[2]
	var them = state.races[them_key]

	var system = state.galaxy.systems[0]
	print("----actions----")
	for key in me.race.diplomacy_actions:
		var action = parse_diplomacy_message(me.race.diplomacy_actions[key], me, you, them, system)
		print(action)

	print("----responses----")
	for key in me.race.diplomacy_responses:
		var response = parse_diplomacy_message(me.race.diplomacy_responses[key], me, you, them, system)
		print(response)
	pass