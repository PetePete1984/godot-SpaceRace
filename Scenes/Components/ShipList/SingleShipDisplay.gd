extends Control

var ExpChevron = preload("res://Scenes/Components/ShipList/ExpChevron.tscn")

const orbiting = "In Orbit at %s"
const in_system = "in %s System"
const construction = "Under Construction at %s"

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
signal ship_clicked
signal ship_right_clicked(ship)

var current_ship

# TODO: use TextureProgress nodes

# TODO: Click reactions (entire display area is a trigger)
# ship states: on planet, in system, in starlane
# left click: go to planet, go to system, go to galaxy view (this simply backs out of the screen)
# right click: open ship designer

# TODO: Hover reactions: Text color updates to white for highlight

func set_ship(ship):
	# set ship image
	Ship.set_texture(TextureHandler.get_ship(ship.owner, ship.size))
	# get permanent ship parameters
	# (ships should update these whenever their modules are changed)
	# extrapolate icons from parameters
	# draw ship stats
	# (ships should update these whenever their status changes)
	# write ship's name
	ShipName.set_text(ship.ship_name)
	# get the ship's current location
	# if applicable, get the planet's sprite or sun sprite
	if ship.location_planet:
		LocationSprite.set_texture(TextureHandler.get_planet(ship.location_planet, true))
		if ship.active:
			Location.set_text(orbiting % ship.location_planet.planet_name)
		else:
			Location.set_text(construction % ship.location_planet.planet_name)
		Interactor.connect("pressed", self, "on_interaction", ["planet_clicked", ship.location_planet])
	elif ship.location_system:
		LocationSprite.set_texture(TextureHandler.get_star(ship.location_system))
		Location.set_text(in_system % ship.location_system.system_name)
		Interactor.connect("pressed", self, "on_interaction", ["system_clicked", ship.location_system])
	else:
		Interactor.connect("pressed", self, "on_interaction", ["ship_clicked"])

	Interactor.connect("input_event", self, "check_for_right_click")
	current_ship = ship

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