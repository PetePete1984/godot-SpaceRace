extends VBoxContainer

onready var density = get_node("Density")
onready var races = get_node("Races")
onready var atmosphere = get_node("Atmosphere")

var numbers = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func update(options):
	density.set_text("%s Star Cluster" % options.galaxy_size.capitalize())
	races.set_text("%s Species" % numbers[options.races].capitalize())
	atmosphere.set_text("%s Atmosphere" % options.atmosphere.capitalize())
