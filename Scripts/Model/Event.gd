# class Event
# gameplay events
extends Reference

enum event_type {CONSTRUCTION, FREE_POP, SPECIAL_ABILITY, RESEARCH_AVAILABLE, 
	RESEARCH_COMPLETE, SPACE_EXPLORATION, SPACE_EXPLORATION_INFO, RACE_SHIP_CONTACT}

var type = null

var images = []
var text = []

var buttons = []
var targets = []