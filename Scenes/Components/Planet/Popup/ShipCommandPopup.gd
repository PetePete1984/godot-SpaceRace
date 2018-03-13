extends Container

onready var label = get_node("TextureFrame/Content/Label")
onready var buttons = get_node("TextureFrame/Buttons")

signal leave_orbit
signal abandon_ship
signal popup_cancel

func setup_for_ship(ship):
	# name_label.set_text(ship.ship_name)
	if ship.active:
		spawn_leave_button()
	spawn_cancel_button()
	pass

func spawn_leave_button():
	var btn = Button.new()
	btn.set_h_size_flags(SIZE_EXPAND_FILL)
	btn.set_text("Leave Orbit")
	buttons.add_child(btn)
	btn.connect("pressed", self, "_on_leave_orbit")

func spawn_cancel_button():
	var btn = Button.new()
	btn.set_h_size_flags(SIZE_EXPAND_FILL)
	btn.set_text("Cancel")
	buttons.add_child(btn)
	btn.connect("pressed", self, "_on_cancel")

func _on_leave_orbit():
	emit_signal("leave_orbit")
	pass

func _on_abandon():
	emit_signal("abandon_ship")
	pass

func _on_cancel():
	emit_signal("popup_cancel")
	hide()
	queue_free()
	pass