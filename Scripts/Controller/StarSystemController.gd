const ColonyController = preload("res://Scripts/Controller/ColonyController.gd")
const ShipController = preload("res://Scripts/Controller/ShipController.gd")

static func colonize(planet, ship, position, name = null):
	ColonyController.colonize_planet(planet, ship.owner, position, name)
	ShipController.remove_modules("colonizer")

static func invade(planet, ship):
	pass