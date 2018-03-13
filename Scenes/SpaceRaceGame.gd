extends Node

# Local Handlers
onready var ScreenHandler = get_node("ScreenHandler")

# current game data
#var game_state

func _ready():
	#randomize()
	# when the game starts from scratch, ask the game state handler for the most recent save
	# if there is no recent save, initialize with galaxy defaults and pick first race
	#game_state = GameStateHandler.get_most_current_game_state()
	GameStateHandler.get_most_current_game_state()
	
	ScreenHandler.connect_signals()
	ScreenHandler.connect("quit_requested", self, "quit_clean")
	# TODO: events are basically global and can be shown anywhere, but anchor to the screen they're on (basically)
	EventHandler.anchor_object = ScreenHandler.get_node("GalaxyScreen/EventAnchor")
	
	ScreenHandler.title_screen()
	#save_game_state()
	set_process(true)
	set_process_input(true)
	pass
	
func _input(event):
	# check for unicode of accents and discard them
	if event.type == InputEvent.KEY and event.scancode == KEY_ESCAPE and event.is_pressed():
		if event.unicode != 0:
			return
	
	if event.is_action_pressed("ui_cancel"):
		if EventHandler.has_popups():
			EventHandler.dismiss_top()
		else:
			ScreenHandler.return_screen()
	
	# DEBUG keys
	if event.type == InputEvent.KEY and event.is_pressed():
		if event.scancode == KEY_E:
			pass
		if event.scancode == KEY_S:
			GameStateHandler.save_game_state("user://debug_save.json")
		if event.scancode == KEY_L:
			GameStateHandler.load_game_state("user://debug_save.json")

func _process(delta):
	pass

func quit_clean():
	GameStateHandler.GameStatePurger.purge_game_state(GameStateHandler.game_state)
	get_tree().quit()	
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit_clean()