extends Node

var UnCob = preload("res://Scripts/Tools/CobUnpack/UnCob.gd")
var ShpTmpToPng = preload("res://Scripts/Tools/CobUnpack/ShpTmpToPng.gd")
var PalToColors = preload("res://Scripts/Tools/CobUnpack/PalToColors.gd")

var ImageMapper = preload("res://Scripts/Tools/ImageMapper.gd")

var path = "res://Cob"
var cobs = {
	"cob0": {
		"source": "ASCEND00.COB",
		"dest": "cob0"
	},
	"cob1": {
		"source": "ASCEND01.COB",
		"dest": "cob1",
		"check": "cob1/data"
	},
	"cob2": {
		"source": "ASCEND02.COB",
		"dest": "cob2",
		"check": "cob2/data"
	}
}

var shapes = []
var templates = []
var vocs = []
var raws = []

var default_palette

signal processing_finished(success)

func _ready():
	#connect("processing_finished", self, "_quit")
	var uncobbed = _uncob()
	if uncobbed:
		var dir = Directory.new()
		for cob_key in cobs:
			var cob = cobs[cob_key]
			if cob.has("check"):
				var check_path = path.plus_file(cob["check"])
				if not dir.dir_exists(check_path):
					print("Missing check path for ", cob_key, ", did extraction work?")
				else:
					if dir.open(check_path) == OK:
						dir.list_dir_begin()
						var file_name = dir.get_next()
						while file_name != "":
							if not dir.current_is_dir():
								if file_name.extension() == "ascshp":
									shapes.append(dir.get_current_dir().plus_file(file_name))
								if file_name.extension() == "tmp":
									templates.append(dir.get_current_dir().plus_file(file_name))
							file_name = dir.get_next()

		if shapes.size() > 0 or templates.size() > 0:
			default_palette = PalToColors.get_palette("res://Cob/cob1/data/game.pal")
			#set_process(true)

		# TODO: implement custom modifications like greyscale race flags

		# change paths to fit with renamed files
		# TODO: maybe move this outside?
		ImageMapper.map_all()
	else:
		emit_signal("processing_finished", false)
	pass

func _process(delta):
	if default_palette != null and (shapes.size() > 0 or templates.size() > 0):
		if shapes.size() > 0:
			var next_shape = shapes.front()
			ShpTmpToPng.unshape(next_shape, default_palette)
			shapes.pop_front()
		elif templates.size() > 0:
			var next_template = templates.front()
			ShpTmpToPng.unshape(next_template, default_palette)
			templates.pop_front()
	else:
		set_process(false)
		emit_signal("processing_finished", true)

func _uncob():
	var dir = Directory.new()
	for cob_key in cobs:
		var cob = cobs[cob_key]
		var dest = path.plus_file(cob.dest)
		if not dir.dir_exists(dest):
			var file = File.new()
			if not file.file_exists(path.plus_file(cob.source)):
				print("COB File missing: ", cob.source)
				print("Please copy it into the Cob folder!")
				return false
			else:
				UnCob.unpack(cob_key, cob.source, dest)
				# TODO: check if UnCob worked
				return true
			# does this need a file.close()?
				
func _quit():
	get_tree().quit()