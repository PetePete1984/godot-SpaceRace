extends VBoxContainer

var display = preload("res://Scenes/Components/ShipList/SingleShipDisplay.tscn")

signal system_clicked(system)
signal planet_clicked(planet)
signal ship_clicked
signal ship_right_clicked(ship)

func update():
	for c in get_children():
		c.update()

func set_ships(player):
	for d in get_children():
		d.hide()
		d.queue_free()
	for ship in player.ships:
		#var ship = player.ships[s]
		# instance the single ship display scene
		var list_item = display.instance()
		# add it to the list
		add_child(list_item)
		# set its contents
		list_item.set_ship(ship)
		# hook up to its signals, which will just be bubbled upwards
		list_item.connect("system_clicked", self, "_on_signal", ["system_clicked"])
		list_item.connect("planet_clicked", self, "_on_signal", ["planet_clicked"])
		list_item.connect("ship_clicked", self, "_on_signal", ["ship_clicked"])
		list_item.connect("ship_right_clicked", self, "_on_signal", ["ship_right_clicked"])

func _on_signal(object, signal_name):
	if object != null:
		emit_signal(signal_name, object)
	else:
		emit_signal(signal_name)