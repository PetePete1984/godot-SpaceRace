extends Node2D

const TILE_WIDTH = 10
const TILE_HEIGHT = 10

const TILES_X = 10
const OFFSET = Vector2(360, 12)

onready var pop_free = preload("res://Images/Screens/Planet/Workers/free.png")
onready var pop_idle = preload("res://Images/Screens/Planet/Workers/idle.png")
onready var pop_work = preload("res://Images/Screens/Planet/Workers/work.png")

# TODO: maybe make this a tilemap as well for ease of use, no need for so many nodes
# TODO: easiest would be GridContainer with TextureFrames
# ALSO TODO: implement some form of caching so it doesn't update every frame
var sprites = []

var current_total = 0
var current_work = 0
var current_idle = 0

func _ready():
	pass
	
func set_population(planet):
	var alive = planet.population.alive
	var total = planet.population.slots
	var work = planet.population.work
	var idle = planet.population.idle
	
	#var free = total - alive
	if total != current_total or work != current_work or idle != current_idle:
		current_total = total
		current_work = work
		current_idle = idle
		
		for s in range(sprites.size()):
			sprites[s].queue_free()
		sprites = []
		var free = total - alive
		
		# this keeps the position in the row
		var last_index = 0
		
		# iterate over workers
		for w in range(last_index, work):
			make_sprite(w, pop_work)
			last_index = w+1
		
		# iterate over idlers
		for i in range(last_index, idle+work):
			make_sprite(i, pop_idle)
			last_index = i+1
			
		# iterate over free slots
		for f in range(last_index, free+idle+work):
			make_sprite(f, pop_free)
			# likely obsolete
			last_index = f
		
		#print("repainted workers")
	pass
	
func get_offset_vector(index):
	return Vector2((index*TILE_WIDTH) % (TILES_X*TILE_WIDTH), floor(index/TILES_X)*TILE_HEIGHT)
	
func make_sprite(index, texture):
	var s = Sprite.new()
	s.set_texture(texture)
	add_child(s)
	s.set_pos(get_offset_vector(index))
	sprites.append(s)
