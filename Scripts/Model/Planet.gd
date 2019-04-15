# Planet info
extends Reference

# player owning this place, maybe it's enough if the colony knows it
var owner

# the planet's integer ID for save/load purposes
var index

var colony = null

# which system this planet is in
var system
# the planet's position inside the system
var position
# TODO: maybe store original position?

# Usually system.system_name + planet index (inside the system), but can be changed
var planet_name

# size template
var size = "enormous"

# type template
var type = "cornucopia"

# initial max population
var base_population = 0

# planet navigator instance
var navigator = null

# flag for the growth bomb project
var growth_bombed = false

# both cell and building grids could just as well be dictionaries (coordinate, cell/building)
# initial cell grid
var grid = []

# buildings grid
var buildings = []

# orbitals grid
var orbitals = []

# population
var population = {
	"work": 0, # working pop
	"idle": 0, # idle pop (alive - working)
	"alive": 0, # alive pop (grows when pop grows)
	"free": 0, # free slots (slots - alive)
	"slots": 0 # total slots (base + extra slots from buildings)
}

var total_population = 0 setget ,get_total_population

# TODO: methods should probably be in a PlanetController, to keep data separate from interaction
func get_total_population():
	return population.work + population.idle + population.free
	
