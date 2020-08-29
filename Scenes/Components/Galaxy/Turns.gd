extends HBoxContainer

onready var _10k = get_node("10k")
onready var _1k = get_node("1k")
onready var _100 = get_node("100")
onready var _10 = get_node("10")
onready var _1 = get_node("1")
onready var digits = [_10k, _1k, _100, _10, _1]

func _ready():
	for i in range(10):
		var preloading = TextureHandler.get_turn_digit(i)
	pass

func set_color(color):
	# TODO: use materialhandler.. somehow
	_10k.get_material().set_shader_param("Color", mapdefs.galaxy_colors[color])
	pass
	
func set_turn(turn):
	var numbers = null
	if turn >= 99999:
		numbers = [9,9,9,9,9]
	else:
		numbers = [turn % 100000/ 10000, turn % 10000 / 1000, turn % 1000 / 100, turn % 100 / 10, turn % 10]

	for i in range(digits.size()):
		digits[i].set_texture(TextureHandler.get_turn_digit(numbers[i]))
