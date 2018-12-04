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
		make_button("OK")
	elif type == "construction":
		make_button("Go to Planet", "planet_picked", target)
	elif type == "research":
		make_button("Go to Research", "research", target)
	pass

func make_button(text_label, signal_name = null, signal_target = null):
	var btn = Button.new()
	btn.set_h_size_flags(SIZE_EXPAND_FILL)
	btn.set_text(text_label)
	buttons.add_child(btn)
	btn.connect("pressed", self, "on_button", [signal_name, signal_target])

func on_button(signal_name = null, target = null):
	hide()
	if signal_name != null:
		if target != null:
			emit_signal(signal_name, target)
		else:
			emit_signal(signal_name)
	dismiss()
	
func dismiss():
	emit_signal("event_dismissed")
	queue_free()
	