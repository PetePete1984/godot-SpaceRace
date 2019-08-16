# class EventGenerator
extends Reference

const GameplayEvent = preload("res://Scripts/Model/Event.gd")
const CONSTRUCTION = "Construction of %s is complete on %s."
const POPULATION = "%s has %d free population for additional projects."
const SPECIAL_ABILITY_INFO = ""
const SPECIAL_ABILITY_READY = "Your species has amassed enough energy to use its special ability."
const RESEARCH_AVAILABLE = "%s Scientist Report: A laboratory has been constructed and we are ready to begin researching new technologies."
const RESEARCH_COMPLETE = "%s Science Report: Our researchers have discovered %s."
const SPACE_EXPLORATION = "%s Scientist Report: We now have all technology needed to build our first ship to explore other stars. This includes generators, engines, and star lane drives."
const SPACE_EXPLORATION_INFO = "Generators provide power for all components on a ship, engines provide movement within star systems, and star drives provide movement through star lanes.\n\nWith continued research we'll be able to improve these.\n\nShips can be built by clicking on an empty orbital square on a planet that has a Shipyard."
const RACE_SHIP_CONTACT = "An unidentified ship has entered the %s system which we occupy. They seem to be contacting us."
const SHIP_ENTERED_ORBIT = "%s: We've entered orbit around %s. Awaiting orders."
const SHIP_SYSTEM_ARRIVAL = "%s: We've arrived at the %s System. Awaiting orders."
const HOSTILE_SHIPS_REMAINING_MOVES = "There are remaining moves in the %s System, which contains hostile ships. Move to next day anyway?"
#{CONSTRUCTION, FREE_POP, SPECIAL_ABILITY, 
#	RESEARCH_COMPLETE, SPACE_EXPLORATION, RACE_SHIP_CONTACT, SHIP_SYSTEM_ARRIVAL}

# TODO: add custom event for ships "Construction of Ship 'Name' is complete"
static func generate_construction(project, planet):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.CONSTRUCTION
	var project_image
	var project_text
	if project.type == "Surface":
		project_image = TextureHandler.get_surface_building(project.project)
		project_text = CONSTRUCTION % [BuildingDefinitions.get_name(project.project), planet.colony.colony_name]
		#project_text = CONSTRUCTION % [BuildingDefinitions.building_defs[project.project].building_name, planet.colony.colony_name]
	elif project.type == "Orbital":
		# TODO: I think this check is doubled in TextureHandler.gd:145 etc
		if project.sub_type != null and project.sub_type.begins_with("Ship"):
			project_image = TextureHandler.get_orbital_building(project, planet.colony.owner)
		else:
			project_image = TextureHandler.get_orbital_building(project.project, planet.colony.owner)
		project_text = CONSTRUCTION % [OrbitalDefinitions.get_name(project.project), planet.colony.colony_name]
		#project_text = CONSTRUCTION % [OrbitalDefinitions.orbital_defs[project.project].orbital_name, planet.colony.colony_name]
	elif project.type == "Tech":
		project_image = TextureHandler.get_tech_project(project.project)
		project_text = CONSTRUCTION % [TechProjectDefinitions.get_name(project.project), planet.colony.colony_name]
		#project_text = CONSTRUCTION % [TechProjectDefinitions.project_defs[project.project].project_name, planet.colony.colony_name]
	var planet_image = TextureHandler.get_planet(planet, true)
	ev.images = [project_image, planet_image]
	var top_line = project_text
	var bottom_line = POPULATION % [planet.colony.colony_name, planet.population.idle]
	ev.text = [top_line, bottom_line]
	ev.buttons = ["construction", "OK"]
	ev.targets = [planet, null]
	return ev

static func generate_free_pop(planet):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.FREE_POP
	var planet_image = TextureHandler.get_planet(planet, true)
	var free_pop_image = TextureHandler.get_person("idle")
	ev.images = [planet_image, free_pop_image]
	var top_line = POPULATION % [planet.colony.colony_name, planet.population.idle]
	ev.text = [top_line]
	ev.buttons = ["construction", "OK"]
	ev.targets = [planet, null]
	return ev
	
static func generate_special_ability():
	pass
	
static func generate_research_available(player):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.RESEARCH_AVAILABLE
	var race_image = TextureHandler.get_race_icon(player.race)
	ev.images = [race_image]
	var top_line = RESEARCH_AVAILABLE % [player.race.race_name]
	var bottom_line = "Research topics are chosen in the research screen."
	ev.text = [top_line, bottom_line]
	ev.buttons = ["research", "OK"]
	ev.targets = [player, null]
	return ev
	
static func generate_research_complete(player, research):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.RESEARCH_COMPLETE
	var research_image = TextureHandler.get_research_icon(research)
	ev.images = [research_image]
	var top_line = RESEARCH_COMPLETE % [player.race.race_name, ResearchDefinitions.research_defs[research].research_name]
	ev.text = [top_line]
	ev.buttons = ["research", "OK"]
	ev.targets = [player, null]
	return ev

static func generate_space_exploration(player):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.SPACE_EXPLORATION
	var race_image = TextureHandler.get_race_icon(player.race)
	ev.images = [race_image]
	var top_line = SPACE_EXPLORATION % [player.race.race_name]
	ev.text = [top_line]
	ev.buttons = ["OK"]
	ev.targets = [null]
	return ev

static func generate_space_exploration_info():
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.SPACE_EXPLORATION_INFO
	var top_line = SPACE_EXPLORATION_INFO
	ev.text = [top_line]
	ev.buttons = ["OK"]
	ev.targets = [null]
	return ev
		
static func generate_race_ship_contact():
	pass

static func generate_ship_entered_orbit(ship):
	pass

static func generate_ship_system_arrival(ship):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.SHIP_SYSTEM_ARRIVAL
	var ship_image = TextureHandler.get_ship(ship.owner, ship.size)
	var star_image = TextureHandler.get_star(ship.location_system)
	ev.images = [ship_image, star_image]
	var system_data = ship.location_system
	var planets = 0
	var lanes = 0
	var enemies = []
	#prints("Ship Name:", ship.ship_name, "System: ", ship.location_system, "System Name: ", ship.location_system.system_name)
	var top_line = SHIP_SYSTEM_ARRIVAL % [ship.ship_name, ship.location_system.system_name]
	ev.text = [top_line]
	ev.buttons = ["system", "OK"]
	ev.targets = [system_data, null]
	return ev

static func generate_warning_no_project(planet):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.FREE_POP_NO_PROJECT
	var planet_image = TextureHandler.get_planet(planet, true)
	var top_line = "%s in the %s system has free population, but no project assigned"
	ev.images = [planet_image]
	ev.text = [top_line]
	ev.buttons = ["planet", "auto", "manage", "OK"]
	ev.targets = [planet, planet, planet, null]
	return ev