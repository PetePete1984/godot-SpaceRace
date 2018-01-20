extends TextureButton

var hoverColor = Color(1.5, 1.5, 1.5, 1)
var normalColor = Color(1, 1, 1, 1)
var toggleColor = Color(1.5, 0.3, 0.3, 1)

# FIXME: Buttons get stuck in hover state when screens are left using ESC while hovering

func _ready():
	connect("mouse_enter", self, "_on_mouse_enter")
	connect("mouse_exit", self, "_on_mouse_exit")
	connect("toggled", self, "_on_toggled")
	if is_pressed():
		set_modulate(toggleColor)
	pass

func _on_mouse_enter():
	set_modulate(hoverColor)
	
func _on_mouse_exit():
	if not is_pressed():
		set_modulate(normalColor)
	else:
		set_modulate(toggleColor)
	
func _on_toggled(pressed):
	if pressed:
		set_modulate(toggleColor)
	else:
		set_modulate(normalColor)
	pass