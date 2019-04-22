extends VBoxContainer

var display = preload("res://Scenes/Components/ShipList/SingleShipDisplay.tscn")

signal system_clicked(system)
signal planet_clicked(planet)
signal ship_clicked(ship)
signal ship_right_clicked(ship)

func update_list():
	var current_ships = get_children()
	if current_ships.size() > 0:
		var owner = current_ships[0].current_ship.owner
		if owner.ships.size() != current_ships.size():
			set_ships(owner)
		else:
			for c in get_children():
				c.update_display()
	else:
		clear_display()

func set_ships(player):
	clear_display()
	for ship in player.ships:
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

func clear_display():
	for d in get_children():
		d.hide()
		d.queue_free()
		remove_child(d)
		
func _on_signal(object, signal_name):
	if object:
		emit_signal(signal_name, object)
	else:
		emit_signal(signal_name)