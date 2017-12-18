extends Reference

const path = "res://Data/newgame.txt"

static func read_descriptions():
	var races = []
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		while not file.eof_reached():
			races.append(file.get_line())
		file.close()
	return races