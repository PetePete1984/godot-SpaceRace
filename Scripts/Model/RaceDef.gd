# race def
extends Reference

var type = ""
var race_name = ""
var race_description = ""
var race_history = {}
var special_ability = null
var index = -1

# TODO: might need a tag list to generalize passive abilities
var race_traits = []

var home_size = null
var home_type = null

var diplomacy_actions = {}
var diplomacy_responses = {}
var diplomacy_thresholds = {}

# TODO: find a way to auto-generate dicts from any class - maybe var2str to json to dict?
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
		"diplomacy_responses": diplomacy_responses,
		"diplomacy_thresholds": diplomacy_thresholds
	}
	return result