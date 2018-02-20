extends VBoxContainer

var display = preload("res://Scenes/Components/ShipList/SingleShipDisplay.tscn")

func update():
	for c in get_children():
		c.update()

func set_ships(player):
	for d in get_children():
		d.hide()
		d.queue_free()
	for s in player.ships:
		var ship = player.ships[s]
		var list_item = display.instance()
		add_child(list_item)
		list_item.set_ship(ship)