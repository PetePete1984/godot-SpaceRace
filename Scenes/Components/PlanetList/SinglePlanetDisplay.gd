extends Control

signal system_clicked(system)
signal planet_clicked(planet)

onready var Flag = get_node("FlagAnchor/Flag")
onready var SunIcon = get_node("SunAnchor/Sun")
onready var PlanetIcon = get_node("PlanetAnchor/Planet")

onready var Research = get_node("ResearchAnchor/Research")
onready var Industry = get_node("IndustryAnchor/Industry")
onready var Prosperity = get_node("ProsperityAnchor/Prosperity")

onready var Workers = get_node("WorkersAnchor")

onready var SystemName = get_node("SystemName")
onready var PlanetName = get_node("HBoxContainer/PlanetName")
onready var PlanetDesc = get_node("HBoxContainer/PlanetDesc")
onready var Project = get_node("Project")

onready var SystemButton = get_node("SystemButton")
onready var PlanetButton = get_node("PlanetButton")

var shows_planet = null
	
func set_planet(planet):
	shows_planet = planet
	update_display()
	connect_buttons(planet)
	
func update_display():
	# TODO: remember planet state in planets so they can be marked dirty only on change
	# TODO: orbitals are shown as icons (shipyard, orbital dock)
	# TODO: worker display
	var planet = shows_planet
	Flag.set_texture(TextureHandler.get_race_flag(planet.owner))
	SunIcon.set_texture(TextureHandler.get_star(planet.system))
	
	var small_planet = true
	PlanetIcon.set_texture(TextureHandler.get_planet(planet, small_planet))
	
	Research.set_texture(TextureHandler.get_research(planet))
	Industry.set_texture(TextureHandler.get_industry(planet))
	Prosperity.set_texture(TextureHandler.get_prosperity(planet))
	
	set_workers(planet)
	
	SystemName.set_text(planet.system.system_name)
	PlanetName.set_text(planet.colony.colony_name)
	PlanetDesc.set_text("(%s %s Planet)" % [planet.size.capitalize(), planet.type.capitalize()])
	if planet.colony.project != null:
		var project = planet.colony.project
		var project_name
		if project.type == "Surface":
			project_name = BuildingDefinitions.building_defs[project.project].building_name
		elif project.type == "Orbital":
			project_name = OrbitalDefinitions.orbital_defs[project.project].orbital_name
		elif project.type == "Tech":
			project_name = TechProjectDefinitions.project_defs[project.project].project_name
		var proj_text = project_name
		var remaining = project.remaining_industry
		var planet_industry = planet.colony.adjusted_industry
		if planet_industry == 0:
			proj_text += " (No industry)"
		else:
			# TODO: move formula to single place (gamerules)
			var days = ceil(float(remaining) / float(planet_industry))
			proj_text += " (%d days)" % [days]
		if project.continuous:
			proj_text = project_name
		Project.set_text(proj_text)
	else:
		var no_proj_text = "No Project"
		if planet.population.idle == 0:
			no_proj_text += " (No free population)"
		Project.set_text(no_proj_text)
	pass
	
func connect_buttons(planet):
	# TODO: check for prior connection before connecting, don't disconnect
	# TODO: or maybe disconnect to refresh?
	if SystemButton.is_connected("pressed", self, "_on_system_pressed"):
		SystemButton.disconnect("pressed", self, "_on_system_pressed")
	SystemButton.connect("pressed", self, "_on_system_pressed", [planet.system])
		
	if PlanetButton.is_connected("pressed", self, "_on_planet_pressed"):
		PlanetButton.disconnect("pressed", self, "_on_planet_pressed")
	PlanetButton.connect("pressed", self, "_on_planet_pressed", [planet])
	
func set_workers(planet):
	# TODO: implement generic worker display that works on both list and planet screens
	# Workers.set_workers(planet)
	pass
	
func _on_system_pressed(system):
	emit_signal("system_clicked", system)
	
func _on_planet_pressed(planet):
	emit_signal("planet_clicked", planet)