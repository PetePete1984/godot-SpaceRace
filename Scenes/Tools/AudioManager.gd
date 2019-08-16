extends Node

var samples = []
var music = {}
var music_tracks = []

var previous_track
var current_track
var music_pos = 0.0

var sounds_path = "res://Audio/Sounds"
var music_path = "res://Audio/Music"

var sounds_volume = 1.0
var music_volume = 1.0

onready var sample_player = get_node("SamplePlayer")
onready var stream_player = get_node("StreamPlayer")
onready var music_player = get_node("MusicPlayer")

func _ready():
	AudioServer.set_fx_global_volume_scale(sounds_volume)
	AudioServer.set_stream_global_volume_scale(music_volume)
	yield(get_tree(), "idle_frame")
	load_samples(sounds_path, sample_player)
	load_streams(music_path)
	#load_samples(music_path, music_player)
	stream_player.connect("finished", self, "_on_music_finished")

	play_music("theme00")

func _process(delta):
	if stream_player.get_volume() <= 1.0:
		var vol = stream_player.get_volume() + (delta)
		if vol >= 1.0:
			vol = 1.0
			set_process(false)
		stream_player.set_volume(vol)

func play(sample):
	if sample_player.get_sample_library().has_sample(sample):
		sample_player.play(sample)

func bleep():
	if sample_player.get_sample_library().has_sample("button"):
		sample_player.play("button")

func load_samples(path, player):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var sample_name = file_name.basename()
				var sample = load(path.plus_file(file_name))
				player.get_sample_library().add_sample(sample_name, sample)
			file_name = dir.get_next()
		dir.list_dir_end()

func load_streams(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with("ogg"):
				var stream_name = file_name.basename()
				var stream = load(path.plus_file(file_name))
				music[stream_name] = stream
				if stream_name.begins_with("theme"):
					music_tracks.append(stream_name)
			file_name = dir.get_next()
		dir.list_dir_end()	

func play_music_sample(which):
	if music_player.get_sample_library().has_sample(which):
		music_player.play(which)

func play_race_music_sample(index):
	var sample = "race%02d" % index
	if music_player.get_sample_library().has_sample(sample):
		music_player.play(sample)

func play_music(which):
	if music.has(which):
		# if already playing music
		if stream_player.is_playing():
			# TODO: if it's race music that's playing and other race music that's requested, don't fall back to previous race music
			# TODO: if it's the same race music that's already playing, restart
			# TODO: so basically unless it's theme music, shelf the theme music and play whatever's requested
			# making previous_track basically previous_theme
			# if it's not the same request
			if previous_track != current_track:
				# keep the previous track
				previous_track = current_track
				# remember where we stopped
				music_pos = stream_player.get_pos()
				# stop and set the new stream
				stream_player.stop()
				stream_player.set_stream(music[which])
				stream_player.play()
				# store what's playing now
				current_track = which
		else:
			# not playing anything yet
			current_track = which
			stream_player.set_stream(music[which])
			stream_player.play()

func play_race_music(index):
	var stream = "race%02d" % index
	play_music(stream)

func _on_music_finished():
	if previous_track == null:
		var next = music_tracks[(music_tracks.find(current_track) + 1) % music_tracks.size()]
		play_music(next)
	elif previous_track != current_track:
		stream_player.set_stream(music[previous_track])
		stream_player.set_volume(0.6)
		set_process(true)
		#stream_player.seek_pos(music_pos)
		stream_player.play(music_pos)
		current_track = previous_track
		previous_track = null