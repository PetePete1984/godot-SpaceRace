extends TextureButton

export (Color) var color

var color_index

func _ready():
	set_modulate(color)

