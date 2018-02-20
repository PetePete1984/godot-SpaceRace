extends PanelContainer

onready var image = get_node("CenterContainer/TextureFrame")
onready var text = get_node("Label")
onready var button = get_node("TextureButton")

signal pressed(module)

var texture
var module_text
var module_key
var set_up = false

func set_module(module):
	texture = TextureHandler.get_ship_module(module)
	module_text = ShipModuleDefinitions.ship_module_defs[module].ship_module_name
	module_key = module

func _ready():
	if not set_up:
		image.set_texture(texture)
		text.set_text(module_text)
		set_tooltip(module_text)
		button.connect("pressed", self, "_on_pressed")
		set_up = true

func _on_pressed():
	emit_signal("pressed", module_key)