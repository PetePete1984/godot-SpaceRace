# Orbital Building Definition
extends Reference

var type = ""
var orbital_name = ""

# override for research names
var research_name = null
# hides orbital in research results (used for the ability to build ships proper)
var hidden_research_result = false
# specific property to load a ship texture for "fake" orbitals that only show up in research
var research_ship_size = null
# corresponding scaling because ship textures are pretty big
var research_ship_scale = null

var orbital_help = ""
var cost = 0
var industry = 0

# will be overriden for dummy projects
var buildable = true
var automatable = true

var replaceable = false

var used_pop = 1
var used_pop_during_construction = 1

var requires_research = null