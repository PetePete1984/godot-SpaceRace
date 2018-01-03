extends CenterContainer

onready var left = get_node("TextureFrame/VBoxContainer/Images/Left")
onready var right = get_node("TextureFrame/VBoxContainer/Images/Right")

onready var top = get_node("TextureFrame/VBoxContainer/Text/Top Line")
onready var bottom = get_node("TextureFrame/VBoxContainer/Text/Bottom Line")

onready var buttons = get_node("TextureFrame/Buttons")

# TODO: rename?
signal planet_picked(planet)
signal research(player)
signal diplomacy(other_player)
signal event_dismissed

func _ready():
	pass

func set_event(event):
	if event.images.size() > 0:
		left.set_texture(event.images[0])
		if event.images.size() > 1:
			right.set_texture(event.images[1])
	
	if event.text.size() > 0:
		top.set_text(event.text[0])
		if event.text.size() > 1:
			bottom.set_text(event.text[1])
			
	if event.buttons.size() > 0 and event.targets.size() > 0:
		for idx in range(event.buttons.size()):
			spawn_button(event.buttons[idx], event.targets[idx])
		pass
	else:
		spawn_button("OK")
	pass
	
func spawn_button(type, target = null):
	if type == "OK":
		var btn = Button.new()
		btn.set_h_size_flags(SIZE_EXPAND_FILL)
		btn.set_text("OK")
		buttons.add_child(btn)
		btn.connect("pressed", self, "_on_ok_button")
	elif type == "construction":
		var btn = Button.new()
		btn.set_h_size_flags(SIZE_EXPAND_FILL)
		btn.set_text("Go to Planet")
		buttons.add_child(btn)
		btn.connect("pressed", self, "_on_planet_button", [target])
	elif type == "research":
		var btn = Button.new()
		btn.set_h_size_flags(SIZE_EXPAND_FILL)
		btn.set_text("Go to Research")
		buttons.add_child(btn)
		btn.connect("pressed", self, "_on_research_button", [target])
	pass
	
func _on_ok_button():
	hide()
	dismiss()
	
func _on_planet_button(planet):
	hide()
	emit_signal("planet_picked", planet)
	dismiss()
	
func _on_research_button(player):
	hide()
	emit_signal("research", player)
	dismiss()
	
func dismiss():
	emit_signal("event_dismissed")
	queue_free()
	