extends Reference
# class PlanetTile
var tiletype = null
var building = null
var buildable = false

# FIXME: I don't really want these in here, currently just using it for finding neighbors
var tilemap_x = 0
var tilemap_y = 0

# tile score for finding the next best upgrade (although this is very basic)
var score = 0
# tile score for finding the best possible colony spot
var colony_score = 0