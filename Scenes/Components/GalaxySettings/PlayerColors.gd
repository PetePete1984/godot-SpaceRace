extends HBoxContainer

onready var color_cursor = get_node("../PlayerColorCursor")
const cursor_pos = Vector2(2, 52)

signal color_picked(color)

func _ready():
	for c in get_children():
		c.color = mapdefs.galaxy_colors[c.get_name().to_upper()]
		c.set_modulate(c.color)
		c.connect("pressed", self, "_picked_color", [c])
	pass

func set_race(race_key):
	var texture = TextureHandler.get_race_flag(race_key)
	for c in get_children():
		c.set_normal_texture(texture)
	pass
	
func set_color(color):
	for c in get_children():
		if c.get_modulate() == color:
			color_cursor.set_pos(cursor_pos + c.get_pos())
			break
	pass
	
func _picked_color(button):
	emit_signal("color_picked", button.color)