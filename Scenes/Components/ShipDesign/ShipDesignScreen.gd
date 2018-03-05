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
onready var ModulePreview = get_node("TileMapAnchor/PlacementPreview")

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

# TODO: move to / use shipDefinitions and whatever the player has researched
var available_ship_sizes = ["small", "medium", "large", "enormous"]

var current_size
var current_category
var current_player
var current_modules = {}
var previous_modules = {}

var selected_module

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

	# link preview sprite to Module map
	ModuleMap.ModulePreview = ModulePreview
	ModuleMap.connect("place_module", self, "_on_place_module")
	ModuleMap.connect("remove_module", self, "_on_remove_module")

	connect("visibility_changed", self, "_on_visibility_changed")
	pass

func _on_visibility_changed():
	if not is_visible():
		# TODO: if module list is empty, the screen is just left without starting a project
		# TODO: leaving a refit without changes does nothing, ship stays active
		# TODO: if any module was set and removed, the ship project is started (this might be a candidate for removal, it's silly (unless you want useless shells that don't move))
		# TODO: refitting one colonizer to a ship at 7 industry takes 10 days, might be double cost; undoing that still sets the cost to 5 days (on a medium)
		if current_modules.keys().size() > 0:
			emit_signal("leaving_with_ship_design", current_size, current_modules)
	else:
		# TODO: previous category is remembered, but not persisted
		set_list_category("generator")
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

	# TODO: existing ship modules must be loaded
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

func cycle_ship_size():
	# TODO: if refitting (previous_modules > 0)
	# TODO: limit sizes to what player can build, obviously
	# TODO: if modules > new_size slots, don't change
	# TODO: dictionary order feels random, modules get thrown all over the place (the original didn't do that)
	var index = available_ship_sizes.find(current_size)
	index += 1
	if index >= available_ship_sizes.size():
		index = 0
	var new_size = available_ship_sizes[index]
	set_ship_size(new_size)
	if current_modules.keys().size() > 0:
		ModuleMap.set_modules(current_modules)

func set_flag(player):
	Flag.set_texture(TextureHandler.get_race_flag(player))

func pick_module(module_key):
	ModuleMap.set_preview(module_key)
	selected_module = module_key

func _on_place_module(position):
	if selected_module != null:
		current_modules[position] = selected_module
		ModuleMap.set_module(position, selected_module)

func _on_remove_module(position):
	if current_modules.has(position):
		current_modules.erase(position)
		ModuleMap.set_module(position, null)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		current_player = null
		current_modules = null
		# cleaning the arrays is enough, since all module nodes are in the tree they'll get freed by godot's normal cleanup
		for k in available_modules:
			available_modules[k] = null
		for k in loaded_modules:
			loaded_modules[k] = null