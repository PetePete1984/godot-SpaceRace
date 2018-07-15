extends Position2D

var SingleItemDisplay = preload("SingleItemDisplay.tscn")

onready var vbox = get_node("ScrollContainer/VBoxContainer")

signal planet_picked(planet)
signal ship_picked(ship)
signal planet_module_picked(planet, module)
signal ship_module_picked(ship, module)

func _ready():
	pass

func clear_items():
	for c in vbox.get_children():
		c.hide()
		c.queue_free()

func view_own_items(player, system):
	clear_items()
	var planets = []
	var ships = []
	for planet in system.planets:
		if planet.owner != null:
			if planet.owner == player:
				planets.append(planet)
	for ship in system.ships:
		if ship.owner != null:
			if ship.owner == player:
				ships.append(ship)

	for planet in planets:
		var display = SingleItemDisplay.instance()
		vbox.add_child(display)
		display.set_planet(planet)
		display.connect_button("Planet")
		display.connect("clicked", self, "_on_planet_clicked", [player, planet])

	for ship in ships:
		var display = SingleItemDisplay.instance()
		vbox.add_child(display)
		display.set_ship(ship)
		display.connect_button("Ship")
		display.connect("clicked", self, "_on_ship_clicked", [player, ship])

	update()
	pass

func view_other_items(player, system):
	clear_items()
	var planets = []
	var ships = []

	for planet in system.planets:
		if planet.owner != null:
			if planet.owner != player:
				planets.append(planet)
		else:
			planets.append(planet)

	for ship in system.ships:
		if ship.owner != null:
			if ship.owner != player:
				ships.append(ship)

	for planet in planets:
		var display = SingleItemDisplay.instance()
		vbox.add_child(display)
		display.set_planet(planet)
		display.connect_button("Planet")
		display.connect("clicked", self, "_on_planet_clicked", [player, planet])

	for ship in ships:
		var display = SingleItemDisplay.instance()
		vbox.add_child(display)
		display.set_ship(ship)
		display.connect_button("Ship")
		display.connect("clicked", self, "_on_ship_clicked", [player, ship])

	update()
	pass

func view_planet_modules(player, planet):
	clear_items()
	print("should have cleared")
	# surface modules: tractor beam
	# orbital modules: missiles, short whopper, long whopper
	pass

func view_ship_modules(player, ship, category):
	clear_items()
	# micro-optimization: could resize result to be as large as the ship's max module count, but that would also mean the iteration over the categorized modules takes longer
	# TODO: better to cache the module lists on the ship instead
	var result = []
	# weapons: list with custom sorting
	if category == "weapon":
		for position in ship.modules:
			var module = ship.modules[position]
			var module_cat = module.module_type.category
			if module_cat != category:
				continue
			else:
				# TODO: sort by module_type.type, then by uses_turn_left
				result.append(module)

	# shields: list with "enabled" state visible
	# specials: only specials that can target are shown
	# misc: includes all modules that can't target or be toggled
	pass

func _on_planet_clicked(player, planet):
	emit_signal("planet_picked", planet)
	#view_planet_modules(player, planet)
	pass

func _on_ship_clicked(player, ship):
	emit_signal("ship_picked", ship)
	#view_ship_modules(player, ship)
	pass

func _on_ship_module_clicked(player, ship, module):

	pass

func _on_planet_module_clicked(player, planet, module):
	pass