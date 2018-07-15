# Ship Module definition

# the string type of the module, from ShipModuleDefinitions.gd
var type = ""
var ship_module_name = ""

# the module's category, assigned from the defs
# one of ["weapon", "shield", "drive", "scanner", "generator", "special"]
var category
var power_drain
var uses
var uses_per_turn
# game data: level
var strength
var module_range

var requires_research = null
var cost

var effect_function
var index


# game data: flag 0
var targets_ships = false
# game data: flag 1
var targets_lane = false
# game data: flag 2
var targets_orbitals = false
# game data: flag 3
var targets_planet_surface = false
# game data: flag 4
var targets_friendly = false
# game data: flag 5
var toggleable = false
# game data: flag 6
var requires_target = false
# game data: flag 7
var passive = false
