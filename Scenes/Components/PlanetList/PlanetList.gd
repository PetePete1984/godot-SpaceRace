extends VBoxContainer

var display = preload("res://Scenes/Components/PlanetList/SinglePlanetDisplay.tscn")

func _ready():
	pass
	
func update():
	for c in get_children():
		c.update()
	pass

func set_planets(player, parent):
	for d in get_children():
		d.hide()
		d.queue_free()
	for c in player.colonies:
		var colony = player.colonies[c]
		var list_item = display.instance()
		add_child(list_item)
		list_item.set_planet(colony.planet)
		list_item.connect("system_clicked", parent, "_on_system_clicked")
		list_item.connect("planet_clicked", parent, "_on_planet_clicked")
	pass