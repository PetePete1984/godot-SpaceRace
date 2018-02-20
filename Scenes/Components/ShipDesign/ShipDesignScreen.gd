extends "res://Scripts/Model/Screen.gd"

var SingleModuleDisplay = preload("res://Scenes/Components/Shipdesign/SingleModuleDisplay.tscn")

onready var Flag = get_node("Flag")

onready var Categories = get_node("CategoryButtons")
onready var Weapons = Categories.get_node("Weapons")
onready var Drives = Categories.get_node("Drives")
onready var Scanners = Categories.get_node("Scanners")
onready var Generators = Categories.get_node("Generators")
onready var Shields = Categories.get_node("Shields")
onready var Modules = Categories.get_node("Modules")

onready var ShipTitle = get_node("TextAnchor/Label")
onready var ShipSize = get_node("SizeButton/TextureButton")
onready var ShipPreview = get_node("ShipPreview/TextureFrame")

onready var ModuleMap = get_node("TileMapAnchor/TileMap_Modules")

onready var SelectedModule_Label = get_node("SelectedGizmoDisplay/VBoxContainer/Label")
onready var SelectedModule_Image = get_node("SelectedGizmoDisplay/VBoxContainer/CenterContainer/TextureFrame")

onready var ModuleList = get_node("GizmoListAnchor/ScrollContainer/VBoxContainer")

var available_modules = {
	"weapon": [],
	"shield": [],
	"drive": [],
	"scanner": [],
	"generator": [],
	"special": []
}

var loaded_modules = {
	"weapon": [],
	"shield": [],
	"drive": [],
	"scanner": [],
	"generator": [],
	"special": []
}

# TODO: move to / use shipDefinitions
var available_ship_sizes = ["small", "medium", "large", "enormous"]

var current_size
var current_category
var current_player
var current_modules = []

signal leaving_with_ship_design(size, modules)

func _ready():
	for key in ShipModuleDefinitions.ship_module_types:
		var def = ShipModuleDefinitions.ship_module_defs[key]
		# preload all modules
		if def.category != null:
			var module_display = SingleModuleDisplay.instance()
			module_display.set_module(key)
			loaded_modules[def.category].append(module_display)
			ModuleList.add_child(module_display)
			module_display.connect("pressed", self, "pick_module")
			module_display.hide()
		# TODO: add buttons to modules and connect to them
	ShipSize.connect("pressed", self, "cycle_ship_size")

	Weapons.connect("pressed", self, "set_list_category", ["weapon"])
	Drives.connect("pressed", self, "set_list_category", ["drive"])
	Scanners.connect("pressed", self, "set_list_category", ["scanner"])
	Generators.connect("pressed", self, "set_list_category", ["generator"])
	Shields.connect("pressed", self, "set_list_category", ["shield"])
	Modules.connect("pressed", self, "set_list_category", ["special"])

	connect("visibility_changed", self, "_on_visibility_changed")
	pass

func _on_visibility_changed():
	if not is_visible():
		emit_signal("leaving_with_ship_design", current_size, current_modules)
	else:
		set_list_category("weapon")
		pass

func set_player(player):
	current_player = player
	for category_key in loaded_modules:
		var category_modules = loaded_modules[category_key]
		for module in category_modules:
			var module_key = module.module_key
			var def = ShipModuleDefinitions.ship_module_defs[module_key]
			if def.requires_research in player.completed_research:
				available_modules[category_key].append(module)
	pass

func set_ship(ship = null):
	# filter modules when player is set
	var size
	if ship != null:
		size = ship.size
	else:
		# TODO: use a default from defs
		size = "small"

	current_size = size
	set_ship_size(size)
	pass

func set_ship_size(size):
	# docked = true
	ShipPreview.set_texture(TextureHandler.get_ship(current_player, size, true))
	ModuleMap.set_template(size)
	current_size = size
	# TODO: set name / title of ship
	# race, size, optional build time
	# Minions "Medium", x days
	# TODO: if modules are loaded, redistribute them

func set_list_category(category):
	if not category == current_category:
		var current = ModuleList.get_children()
		for c in current:
			c.hide()
		for c in available_modules[category]:
			c.show()

func choose_module(module):
	pass

func cycle_ship_size():
	# TODO: if modules > new_size slots, don't change
	var index = available_ship_sizes.find(current_size)
	index += 1
	if index >= available_ship_sizes.size():
		index = 0
	var new_size = available_ship_sizes[index]
	set_ship_size(new_size)

func set_flag(player):
	Flag.set_texture(TextureHandler.get_race_flag(player))

func pick_module(module_key):
	print(module_key)

func set_module(position, module = null):
	pass

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		current_player = null
		current_modules = null
		for k in available_modules:
			available_modules[k] = null
		for k in loaded_modules:
			for c in loaded_modules[k]:
				if c.is_inside_tree():
					c.queue_free()
				else:
					c.free()
