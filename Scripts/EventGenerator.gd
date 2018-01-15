# class EventGenerator
extends Node

const GameplayEvent = preload("res://Scripts/Model/Event.gd")
const POPULATION = "%s has %d free population for additional projects."
const RESEARCH_AVAILABLE = "%s Scientist Report: A laboratory has been constructed and we are ready to begin researching new technologies."
const RESEARCH_COMPLETE = "%s Science Report: Our researchers have discovered %s."
const SPACE_EXPLORATION = "%s Scientist Report: We now have all technology needed to build our first ship to explore other stars. This includes generators, engines, and star lane drives."
const SPACE_EXPLORATION_PAGE2 = ""
#{CONSTRUCTION, FREE_POP, SPECIAL_ABILITY, 
#	RESEARCH_COMPLETE, SPACE_EXPLORATION, RACE_SHIP_CONTACT}

static func generate_construction(project, planet):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.CONSTRUCTION
	var project_image = TextureHandler.get_surface_building(project)
	var planet_image = TextureHandler.get_planet(planet, true)
	ev.images = [project_image, planet_image]
	var top_line = "Construction of %s is complete on %s." % [BuildingDefinitions.building_defs[project].building_name, planet.colony.name]
	var bottom_line = POPULATION % [planet.colony.name, planet.population.idle]
	ev.text = [top_line, bottom_line]
	ev.buttons = ["construction", "OK"]
	ev.targets = [planet, null]
	return ev

func generate_free_pop(planet):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.FREE_POP
	var planet_image = TextureHandler.get_planet(planet, true)
	var free_pop_image = TextureHandler.get_person("idle")
	ev.images = [planet_image, free_pop_image]
	var top_line = POPULATION % [planet.colony.name, planet.population.idle]
	ev.text = [top_line]
	ev.buttons = ["construction", "OK"]
	ev.targets = [planet, null]
	return ev
	
func generate_special_ability():
	pass
	
func generate_research_available(player):
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
	
func generate_research_complete(player, research):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.RESEARCH_COMPLETE
	var research_image = TextureHandler.get_research_icon(research)
	ev.images = [research_image]
	var top_line = RESEARCH_COMPLETE % [player.race.race_name, ResearchDefinitions.research_defs[research].research_name]
	ev.text = [top_line]
	ev.buttons = ["research", "OK"]
	ev.targets = [player, null]
	return ev
	pass

func generate_space_exploration(player):
	var ev = GameplayEvent.new()
	ev.type = GameplayEvent.SPACE_EXPLORATION
	var race_image = TextureHandler.get_race_icon(player.race)
	ev.images = [race_image]
	var top_line = SPACE_EXPLORATION % [player.race.race_name]
	ev.text = [top_line]
	ev.buttons = ["OK"]
	ev.targets = [null]
	return ev
	pass
	
func generate_space_exploration_info():
	pass
	
func generate_race_ship_contact():
	pass