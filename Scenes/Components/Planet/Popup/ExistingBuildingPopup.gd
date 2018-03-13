extends Container
# Laboratory on Blue Square

# Automate / Abandon / Cancel

# NEW: Replace / Upgrade

onready var label = get_node("TextureFrame/Content/Label")
onready var buttons = get_node("TextureFrame/Buttons")

signal automate(building, tile, position)
signal abandon(building, tile, position)
signal cancel

const label_format = "%s on %s square"

func set_building(building_tile, tile, position, planet):
	# TODO: if tiles become enums, name must be elsewhere
	# TODO: "automated" has different label
	label.set_text(label_format % [building_tile.type.building_name, tile.tiletype.capitalize()])

	pass

func _on_automate():
	pass

func _on_abandon():
	pass

func _on_cancel():
	pass