extends Node

# Screens
onready var TitleScreen = get_node("TitleScreen")
onready var GalaxySettingsScreen = get_node("GalaxySettingsScreen")
onready var RaceIntroScreen = get_node("RaceIntroScreen")
onready var GalaxyScreen = get_node("GalaxyScreen")
onready var PlanetListScreen = get_node("PlanetListScreen")
onready var ShipListScreen = get_node("ShipListScreen")
onready var ResearchScreen = get_node("ResearchScreen")
onready var RaceOverviewScreen = get_node("RaceOverviewScreen")
onready var RaceListScreen = get_node("RaceListScreen")
onready var BattleScreen = get_node("BattleScreen")
onready var PlanetScreen = get_node("PlanetScreen")
onready var ShipDesignScreen = get_node("ShipDesignScreen")

signal leaving_screen

# screen stack
var screens = []
var current_screen

func _ready():
	pass

func connect_signals():
	# connect turn display
	TurnHandler.connect("turn_finished", self, "_update_turn")
	
	# connect title screen buttons
	TitleScreen.connect("new_game", self, "request_new_game")
	TitleScreen.connect("resume_game", self, "init_gameplay")
	
	# connect "new game" on settings screen
	GalaxySettingsScreen.connect("galaxy_init", self, "use_galaxy_options_and_show_intro")

	# connect to finishing the race intro text
	RaceIntroScreen.connect("start_game", self, "init_gameplay")

	# connect to a click on a system
	GalaxyScreen.connect("system_picked", self, "_system_view")
	# connect main buttons
	GalaxyScreen.connect("planetlist_requested", self, "_planetlist_view")
	GalaxyScreen.connect("research_requested", self, "_research_view")
	
	# connect to a click on a planet
	BattleScreen.connect("planet_picked", self, "_planet_view")
	
	# connect to buttons on event popups
	EventHandler.connect("planet_picked", self, "_planet_view")
	EventHandler.connect("research", self, "_research_view")
	
	PlanetListScreen.connect("system_clicked", self, "_system_view")
	PlanetListScreen.connect("planet_clicked", self, "_planet_view")

	# gameplay signals
	GalaxyScreen.connect("next_requested", self, "_next_turn_requested")
	GalaxyScreen.connect("auto_requested", self, "_auto_requested")
	pass

func return_screen():
	# New Game selected & confirmed: move forward
	if current_screen == RaceIntroScreen:
		init_gameplay()
	if screens.size() > 1:
		screens.back().hide()
		screens.pop_back()
		# TODO: if multiple are visible (galaxy + species < intelligence), find something else
		# TODO: returning from planet to planet list after starting a project must update planet list
		screens.back().show()
		emit_signal("leaving_screen")
	else:
		get_tree().quit()
	pass

func title_screen():
	set_payload(TitleScreen, GameStateHandler.game_state)
	move_to_screen(TitleScreen)
	
func use_galaxy_options_and_show_intro(galaxy_options, race_key, color):
	RaceIntroScreen.setup_display(galaxy_options, race_key, color)
	GameStateHandler.initialize_galaxy(galaxy_options, race_key, color)
	GalaxyScreen.set_color(color)
	move_to_screen(RaceIntroScreen)
	pass
	
func _next_turn_requested():
	TurnHandler.game_turn()
	
func _auto_requested(enable):
	TurnHandler.auto(enable)
	
func _update_turn():
	GalaxyScreen.update_game_state(GameStateHandler.game_state)

func _galaxy_view(game_state):
	set_payload(GalaxyScreen, game_state)
	move_to_screen(GalaxyScreen)

func _research_view(player = null):
	# FIXME: find current human player
	ResearchScreen.show_research(GameStateHandler.game_state.human_player)
	move_to_screen(ResearchScreen)
	pass
	
func _planetlist_view(player = null):
	# FIXME: find current human player
	PlanetListScreen.set_player(GameStateHandler.game_state.human_player)
	move_to_screen(PlanetListScreen)
	
func _system_view(system):
	set_payload(BattleScreen, system)
	move_to_screen(BattleScreen)
	pass
	
func _planet_view(planet):
	set_payload(PlanetScreen, planet)
	move_to_screen(PlanetScreen)
	pass

func request_new_game():
	GalaxySettingsScreen.reset()
	move_to_screen(GalaxySettingsScreen)
	#emit_signal("new_game_requested")
	pass

func init_gameplay():
	reset_screens()
	set_payload(GalaxyScreen, GameStateHandler.game_state)
	move_to_screen(GalaxyScreen)
	
func reset_screens():
	for screen in screens:
		screen.hide()
	screens = [TitleScreen]
	
func set_payload(screen, payload):
	screen.set_payload(payload)

func move_to_screen(screen):
	if not screen.is_overlay():
		if screens.size() > 0:
			var previous_screen = screens.back()
			if previous_screen:
				previous_screen.hide()
				pass
	#screen.set_payload(payload)
	screen.show()
	screens.append(screen)
#	var children = get_children()
#	for c in range(children.size()):
#		var child = children[c]
#		child.hide()
#		if child == screen:
#			child.show()

