# Building Definition
extends Reference
var type = ""
var building_name = ""
var building_help = ""
var cost = 0
var industry = 0
var prosperity = 0
var research = 0
# can this be built at all
var buildable = true

# can this be abandoned and / or replaced
var replaceable = true
# list of buildings that can be replaced by this (exclusive)
var replaces = null
# list of buildings that can replace this (exclusive)
var replaced_by = null

# can this be automated
var automatable = true

var used_pop_during_construction = 1
var used_pop = 1
var provided_pop = 0

var requires_research = null

# TODO: usability: add a limit of 1 that at least triggers a warning for buildings like the hyperpower