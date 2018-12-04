extends Node

# provides convenient access to most classes that were preloaded separately in various scripts before

# single scripts / classes
const Planet = preload("res://Scripts/Model/Planet.gd")
const Planetmap = preload("res://Scripts/Planetmap.gd")
const Ship = preload("res://Scripts/Model/Ship.gd")

# scripted Nodes
const BattlePick = preload("res://Scenes/Components/ClickableArea3D.gd")

# full scenes
const BillboardSprite3D = preload("res://Scenes/Components/BillboardSprite3D.tscn")

const SingleItemDisplay = preload("res://Scenes/Components/Battle/SingleItemDisplay.tscn")

const model = {}

func _ready():
	var base = "res://Scripts"
	var paths = ["Controller", "Definitions", "Factories", "Generator", "Manager", "Model"]
	for path in paths:
		find_all_classes(base.plus_file(path))

func find_all_classes(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if not file_name == "." and not file_name == "..":
					find_all_classes(path.plus_file(file_name))
			if not dir.current_is_dir():
				if file_name.extension() == "gd":
					var base = file_name.basename()
					var resource = load(path.plus_file(file_name))
					if model.has(base):
						print("Clash for ", base)
					model[base] = resource
					self.set(base, resource)
			file_name = dir.get_next()
		dir.list_dir_end()