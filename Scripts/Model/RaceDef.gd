# race def
extends Object

var type = ""
var race_name = ""
var race_description = ""
var race_history = {}
var special_ability = null
var index = -1

var home_size = null
var home_type = null

var diplomacy_actions = {}
var diplomacy_responses = {}

# TODO: find a way to auto-generate dicts from any class
func race_to_dict():
	var result = {
		"type": type,
		"race_name": race_name,
		"race_description": race_description,
		"race_history": race_history,
		"special_ability": special_ability,
		"index": index,
		"home_size": home_size,
		"home_type": home_type,
		"diplomacy_actions": diplomacy_actions,
		"diplomacy_responses": diplomacy_responses
	}
	return result