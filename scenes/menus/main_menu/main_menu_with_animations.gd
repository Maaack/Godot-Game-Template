extends MainMenu

var animation_state_machine : AnimationNodeStateMachinePlayback

func load_game_scene():
	GameState.start_game()
	super.load_game_scene()

func new_game():
	GlobalState.reset()
	load_game_scene()

func intro_done():
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro():
	return animation_state_machine.get_current_node() == "Intro"

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu):
	super._open_sub_menu(menu)
	animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu():
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

func _input(event):
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)

func _ready():
	super._ready()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _setup_game_buttons():
	super._setup_game_buttons()
	if GameState.has_game_state():
		%ContinueGameButton.show()

func _on_continue_game_button_pressed():
	load_game_scene()
