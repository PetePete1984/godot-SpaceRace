extends Node

var EventPopup = preload("res://Scenes/Components/EventPopup.tscn")
var anchor_object

var events = {}
signal planet_picked(planet)
signal research(player)

func _ready():
	pass
	
func clear():
	for r in events:
		events[r].clear()

func add_event(player, event):
	var race = player.race.type
	if not events.has(race):
		events[race] = []
	events[race].append(event)
	pass

func get_events(player):
	if events.has(player.race.type):
		return events[player.race.type]
	else:
		return []
	pass

func get_next_event(player):
	var race = player.race.type
	if events.has(race):
		var event = events[race].back()
		events[race].pop_back()
		return event
	else:
		return null

func display_event(event):
	var pop = EventPopup.instance()
	anchor_object.add_child(pop)
	pop.set_event(event)
	pop.connect("planet_picked", self, "_on_planet_picked")
	pop.connect("research", self, "_on_research")
	pass
	
func _on_planet_picked(planet):
	emit_signal("planet_picked", planet)

func _on_research(player):
	emit_signal("research", player)