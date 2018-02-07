extends VBoxContainer

var display = preload("res://Scenes/Components/PlanetList/SinglePlanetDisplay.tscn")

signal system_clicked(system)
signal planet_clicked(planet)

func _ready():
	pass
	
func update():
	var current_planets = get_children()
	if current_planets.size() > 0:
		var owner = current_planets[0].shows_planet.colony.owner
		if owner.colonies.size() != current_planets.size():
			set_planets(owner)
		else:
			for c in current_planets:
				c.update()
	else:
		clear_display()
	pass

func set_planets(player):
	clear_display()
	for c in player.colonies:
		var colony = player.colonies[c]
		var list_item = display.instance()
		add_child(list_item)
		list_item.set_planet(colony.planet)
		list_item.connect("system_clicked", self, "_on_system_clicked")
		list_item.connect("planet_clicked", self, "_on_planet_clicked")
	pass

func clear_display():
	for d in get_children():
		d.hide()
		d.queue_free()

func _on_system_clicked(system):
	emit_signal("system_clicked", system)

func _on_planet_clicked(planet):
	emit_signal("planet_clicked", planet)