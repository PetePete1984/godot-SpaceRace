extends HBoxContainer

onready var _10k = get_node("10k")
onready var _1k = get_node("1k")
onready var _100 = get_node("100")
onready var _10 = get_node("10")
onready var _1 = get_node("1")

var texture_path = "res://Images/Screens/Galaxy/Layout/Numbers/%d.png"
var textures = {}

func _ready():
	for i in range(10):
		textures[str(i)] = load(texture_path % i)
	pass

func set_color(color):
	_10k.get_material().set_shader_param("Color", color)
	pass
	
func set_turn(turn):
	var numbers = []
	if turn >= 99999:
		numbers = [9,9,9,9,9]
	else:
		numbers.append(turn % 100000/ 10000)
		numbers.append(turn % 10000 / 1000)
		numbers.append(turn % 1000 / 100)
		numbers.append(turn % 100 / 10)
		numbers.append(turn % 10)
	_10k.set_texture(textures[str(numbers[0])])
	_1k.set_texture(textures[str(numbers[1])])
	_100.set_texture(textures[str(numbers[2])])
	_10.set_texture(textures[str(numbers[3])])
	_1.set_texture(textures[str(numbers[4])])
	pass