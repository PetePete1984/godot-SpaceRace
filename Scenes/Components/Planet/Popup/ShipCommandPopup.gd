extends Container

onready var label = get_node("TextureFrame/Content/Label")
onready var buttons = get_node("TextureFrame/Buttons")

signal leave_orbit
signal abandon_ship
signal popup_cancel
signal colonize
signal invade

func setup_for_ship(ship, planet):
	label.set_text(ship.ship_name)
	if ship.active:
		if ship.has_colonizer():# and planet.colony == null:
			spawn_button("Colonize", "colonize")
		elif ship.has_invader() and planet.colony != null and planet.colony.owner != ship.owner:
			# TODO: check diplomacy peace status and use some enum
			if ship.owner.relationship(planet.colony.owner) != "peace":
				spawn_button("Invade", "invade")
		spawn_button("Leave Orbit", "leave_orbit")
	spawn_button("Cancel", "popup_cancel")

func spawn_button(text_label, signal_name):
	var btn = Button.new()
	btn.set_h_size_flags(SIZE_EXPAND_FILL)
	btn.set_text(text_label)
	buttons.add_child(btn)
	btn.connect("pressed", self, "_on_button", [signal_name])

func _on_button(signal_name):
	emit_signal(signal_name)
	hide()
	queue_free()