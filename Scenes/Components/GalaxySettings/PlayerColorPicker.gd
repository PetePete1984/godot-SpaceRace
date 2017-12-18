extends TextureButton

export (Color) var color

func _ready():
	set_modulate(color)
	pass
