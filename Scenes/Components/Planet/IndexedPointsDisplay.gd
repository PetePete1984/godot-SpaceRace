tool
extends TextureButton

# script for a button that loads and caches textures based on an index
# calls TextureHandler to get its textures

export(int) var points = 0 setget set_points

export(String, "Research", "Industry", "Prosperity") var display_type = "Research" setget set_type

onready var points_label = get_node("PointsLabel")

func _ready():
	if points_label == null:
		points_label = get_node("PointsLabel")
	if display_type != "":
		_load_texture()
	pass

func set_points(new_points):
	if display_type != "":
		points = new_points
		if is_inside_tree():
			if points_label == null:
				points_label = get_node("PointsLabel")
			else:
				points_label.set_text(str(points))
		_load_texture()
		
func set_type(type):
	if display_type != type:
		display_type = type
		_load_texture()

func _load_texture():
	var texture = TextureHandler.get_indexed_display(display_type, points)

	if texture != null:
		set_normal_texture(texture)
		update()
	pass
