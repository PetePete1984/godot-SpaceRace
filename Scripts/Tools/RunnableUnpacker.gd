extends SceneTree

const Unpacker = preload("res://Scripts/Tools/CobUnpacker.gd")

func _init():
	var unpacker = Unpacker.new()
	unpacker.process_shapes = true
	unpacker.process_templates = true
	unpacker.process_vocs = false
	unpacker.process_raws = false
	unpacker.process_gifs = true
	unpacker.process_fnts = false
	unpacker.connect("processing_finished", self, "maybe_quit")
	get_root().add_child(unpacker)

func maybe_quit(success):
	if success:
		quit()
