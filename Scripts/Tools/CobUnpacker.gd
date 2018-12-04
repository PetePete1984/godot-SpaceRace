extends Node

var UnCob = preload("res://Scripts/Tools/CobUnpack/UnCob.gd")
var ShpTmpToPng = preload("res://Scripts/Tools/CobUnpack/ShpTmpToPng.gd")
var PalToColors = preload("res://Scripts/Tools/CobUnpack/PalToColors.gd")
var RawToWav = preload("res://Scripts/Tools/CobUnpack/RawToWav.gd")
var VocToWav = preload("res://Scripts/Tools/CobUnpack/VocToWav.gd")
var FntToPng = preload("res://Scripts/Tools/CobUnpack/FntToPng.gd")

var ImageMapper = preload("res://Scripts/Tools/ImageMapper.gd")

var ffmpeg_windows = "res://Cob/ffmpeg.exe"
var ffmpeg_linux = "ffmpeg"

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

var process_shapes = false
var process_templates = false
var process_vocs = false
var process_raws = false
var process_gifs = false
var process_fnts = false

var shapes = []
var templates = []
var vocs = []
var raws = []
var gifs = []
var fnts = []

var cleanup_folders = false

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
								if process_shapes and file_name.extension() == "ascshp":
									shapes.append(dir.get_current_dir().plus_file(file_name))
								if process_templates and file_name.extension() == "tmp":
									templates.append(dir.get_current_dir().plus_file(file_name))
								if process_raws and file_name.extension() == "raw":
									raws.append(dir.get_current_dir().plus_file(file_name))
								if process_vocs and file_name.extension() == "voc":
									vocs.append(dir.get_current_dir().plus_file(file_name))
								if process_gifs and file_name.extension() == "gif":
									gifs.append(dir.get_current_dir().plus_file(file_name))
								if process_fnts and file_name.extension() == "ascfnt":
									fnts.append(dir.get_current_dir().plus_file(file_name))
							file_name = dir.get_next()
						dir.list_dir_end()

		# FIXME: move to extraction function that yields, out of ready
		if shapes.size() > 0 or templates.size() > 0:
			default_palette = PalToColors.get_palette("res://Cob/cob1/data/game.pal")
			#set_process(true)
		
		if shapes.size() > 0:

			pass
		if raws.size() > 0:
			var dir = Directory.new()
			for next_raw in raws:
				var raw_data = RawToWav.unraw(next_raw)
				var wav_written = RawToWav.store(next_raw.replace(".raw", ".wav"), raw_data)
				var path_from = next_raw.replace(".raw", ".wav")
				var file_from = path_from.get_file()
				var path_to = "res://Audio/Music".plus_file(file_from)
				dir.copy(path_from, path_to)
				yield(get_tree(), "idle_frame")
				var os_name = OS.get_name()
				if os_name == "Windows":
					var output = []
					var pid = OS.execute(Globals.globalize_path(ffmpeg_windows), ["-hide_banner", "-loglevel", "panic", "-y", "-i", Globals.globalize_path("res://Audio/Music".plus_file(file_from)), "-acodec", "libvorbis", Globals.globalize_path("res://Audio/Music".plus_file(file_from).replace(".wav", ".ogg"))], true, output)
					yield(get_tree(), "idle_frame")
				elif os_name == "X11":
					var output = []
					var pid = OS.execute(Globals.globalize_path(ffmpeg_linux), ["-hide_banner", "-loglevel", "panic", "-y", "-i", Globals.globalize_path("res://Audio/Music".plus_file(file_from)), "-acodec", "libvorbis", Globals.globalize_path("res://Audio/Music".plus_file(file_from).replace(".wav", ".ogg"))], true, output)
					yield(get_tree(), "idle_frame")
		if vocs.size() > 0:
			for next_voc in vocs:
				var is_voc = VocToWav.is_voc(next_voc)
				if is_voc:
					var voc_data = VocToWav.unvoc(next_voc)
					var wav_written = VocToWav.store(next_voc, voc_data)
				else:
					#prints(next_voc, "is not a voc file")
					var raw_data = RawToWav.unraw(next_voc)
					var wav_written = RawToWav.store(next_voc.replace(".voc", ".wav"), raw_data)
				var path_from = next_voc.replace(".voc", ".wav")
				var file_from = path_from.get_file()
				var path_to = "res://Audio/Sounds".plus_file(file_from)
				dir.copy(path_from, path_to)
				yield(get_tree(), "idle_frame")
		if gifs.size() > 0:
			for next_gif in gifs:
				var target = next_gif.replace(".gif", "_gif.png")
				#print(target)
				#continue
				var os_name = OS.get_name()
				if os_name == "Windows":
					var output = []
					var pid = OS.execute(Globals.globalize_path(ffmpeg_windows), ["-hide_banner", "-loglevel", "panic", "-y", "-i", Globals.globalize_path(next_gif), Globals.globalize_path(target)], true, output)
					yield(get_tree(), "idle_frame")
				elif os_name == "X11":
					var output = []
					var pid = OS.execute(Globals.globalize_path(ffmpeg_linux), ["-hide_banner", "-loglevel", "panic", "-y", "-i", Globals.globalize_path(next_gif), Globals.globalize_path(target)], true, output)
					yield(get_tree(), "idle_frame")
			pass
		if fnts.size() > 0:
			var logo_palette
			if logo_palette == null:
				logo_palette = PalToColors.get_palette("res://Cob/cob1/data/game.pal")
			for next_fnt in fnts:
				FntToPng.unfnt(next_fnt, logo_palette)
			pass

		if shapes.size() > 0 or templates.size() > 0 or gifs.size() > 0 or fnts.size() > 0:
			# TODO: implement custom modifications like greyscale race flags

			# change paths to fit with renamed files
			# TODO: maybe move this outside? (to include gifs and fnts)
			ImageMapper.map_all()
	
		emit_signal("processing_finished", true)
	else:
		print("Didn't Uncob")
		emit_signal("processing_finished", false)
	pass

func _process(delta):
	# FIXME: move to extraction function that yields, out of process
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
	var uncobbed = {}
	for cob_key in cobs:
		var cob = cobs[cob_key]
		var dest = path.plus_file(cob.dest)
		if not dir.dir_exists(dest):
			var file = File.new()
			if not file.file_exists(path.plus_file(cob.source)):
				print("COB File missing: ", cob.source)
				print("Please copy it into the Cob folder!")
				uncobbed[cob_key] = false
			else:
				UnCob.unpack(cob_key, path.plus_file(cob.source), dest)
				# TODO: check if UnCob worked, but don't use return because that would stop after one file
				uncobbed[cob_key] = true
			# does this need a file.close()?
			file.close()

	for val in uncobbed.values():
		if val != true:
			return false
	return true
				
func _quit():
	get_tree().quit()