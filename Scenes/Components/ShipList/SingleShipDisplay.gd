extends Control

var ExpChevron = preload("res://Scenes/Components/ShipList/ExpChevron.tscn")

const orbiting = "In Orbit at %s"
const in_system = "in %s System"
const in_starlane = "In Starlane to %s System"
const construction = "Under Construction at %s"
const text_eta = "ETA - %d days"

onready var Ship = get_node("HBoxContainer/ShipDisplay")
onready var ShipName = get_node("HBoxContainer/Stats/Name_Exp/ShipName")
onready var Experience = get_node("HBoxContainer/Stats/Name_Exp/Experience")

onready var Attack = get_node("HBoxContainer/Stats/HBoxContainer/Attack")
onready var Shield = get_node("HBoxContainer/Stats/HBoxContainer1/Shield")
onready var Drive = get_node("HBoxContainer/Stats/HBoxContainer2/Drive")
onready var Scanner = get_node("HBoxContainer/Stats/HBoxContainer3/Scanner")
onready var PowerTotal = get_node("HBoxContainer/Stats/HBoxContainer4/Power")

onready var HullStrength = get_node("HBoxContainer/HullVBox/HullStrengthBar")
onready var PowerLeft = get_node("HBoxContainer/PowerVBox/PowerBar")
onready var Location = get_node("HBoxContainer/LocationVBox/Location")
onready var ETA = get_node("HBoxContainer/LocationVBox/ETA")
onready var LocationSprite = get_node("HBoxContainer/SpriteVBox/LocationSprite")

onready var Interactor = get_node("TextureButton")

signal system_clicked(system)
signal planet_clicked(planet)
signal ship_clicked(ship)
signal ship_right_clicked(ship)

var current_ship

# TODO: use TextureProgress nodes for bars

# TODO: Click reactions (entire display area is a trigger)
# ship states: on planet, in system, in starlane
# left click: go to planet, go to system, go to galaxy view (this simply backs out of the screen)
# right click: open ship designer

# TODO: Hover reactions: Text color updates to white for highlight

func set_ship(ship):
	current_ship = ship
	update_display()

func update_display():
	# set ship image
	Ship.set_texture(TextureHandler.get_ship(current_ship.owner, current_ship.size))
	# get permanent ship parameters
	# (ships should update these whenever their modules are changed)
	# extrapolate icons from parameters
	# draw ship stats
	# (ships should update these whenever their status changes)
	# write ship's name
	ShipName.set_text(current_ship.ship_name)
	# get the ship's current location
	# if applicable, get the planet's sprite or sun sprite
	if current_ship.location_planet:
		LocationSprite.set_texture(TextureHandler.get_planet(current_ship.location_planet, true))
		if current_ship.active:
			Location.set_text(orbiting % current_ship.location_planet.planet_name)
		else:
			Location.set_text(construction % current_ship.location_planet.planet_name)
			# TODO: print build time ETA
		if Interactor.is_connected("pressed", self, "on_interaction"):
			Interactor.disconnect("pressed", self, "on_interaction")
		Interactor.connect("pressed", self, "on_interaction", ["planet_clicked", current_ship.location_planet])
	elif current_ship.location_system:
		LocationSprite.set_texture(TextureHandler.get_star(current_ship.location_system))
		Location.set_text(in_system % current_ship.location_system.system_name)
		if Interactor.is_connected("pressed", self, "on_interaction"):
			Interactor.disconnect("pressed", self, "on_interaction")
		Interactor.connect("pressed", self, "on_interaction", ["system_clicked", current_ship.location_system])
	else:
		# probably in a star lane
		LocationSprite.set_texture(null)
		# TODO: implement knowledge for "Unknown" System
		var target = current_ship.starlane_target.system_name
		Location.set_text(in_starlane % target)
		# TODO: ship clicks when in starlane go straight to galaxy screen
		if Interactor.is_connected("pressed", self, "on_interaction"):
			Interactor.disconnect("pressed", self, "on_interaction")
		Interactor.connect("pressed", self, "on_interaction", ["ship_clicked", current_ship])
	if not Interactor.is_connected("input_event", self, "check_for_right_click"):
		Interactor.connect("input_event", self, "check_for_right_click")

func check_for_right_click(event):
	if current_ship != null:
		if event.type == InputEvent.MOUSE_BUTTON:
			if event.button_index == BUTTON_RIGHT:
				if event.is_pressed():
					emit_signal("ship_right_clicked", current_ship)

func on_interaction(signal_name, target = null):
	if target:
		emit_signal(signal_name, target)
	else:
		emit_signal(signal_name)

func set_experience(ship):
	var exp_chevron = ExpChevron.instance()
	var num_chevrons = ship.experience_level
	for i in num_chevrons:
		Experience.add_child(exp_chevron)