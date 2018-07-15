extends Container

onready var label = get_node("PanelContainer/VBoxContainer/Label")
onready var line_edit = get_node("PanelContainer/VBoxContainer/HBoxContainer/LineEdit")
onready var button = get_node("PanelContainer/VBoxContainer/HBoxContainer/Button")

signal popup_closed(result)

func set_ship(ship):
	line_edit.set_placeholder(ship.ship_name)

func _ready():
	button.connect("pressed", self, "_on_confirm_name", [null])
	line_edit.connect("text_entered", self, "_on_confirm_name")

func _on_confirm_name(text = null):
	var new_name = ""
	if text != null:
		new_name = text
	elif line_edit.get_text() != "":
		new_name = line_edit.get_text()
	elif line_edit.get_placeholder() != "":
		new_name = line_edit.get_placeholder()

	emit_signal("popup_closed", new_name)
	hide()
	queue_free()
