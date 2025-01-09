extends MainMenu

@export var level_select_packed_scene: PackedScene

var level_select_scene
var animation_state_machine : AnimationNodeStateMachinePlayback

func load_game_scene():
	GameStateExample.start_game()
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

func _setup_level_select(): 
	if level_select_packed_scene != null:
		level_select_scene = level_select_packed_scene.instantiate()
		level_select_scene.hide()
		%LevelSelectContainer.call_deferred("add_child", level_select_scene)
		if level_select_scene.has_signal("level_selected"):
			level_select_scene.connect("level_selected", load_game_scene)

func _input(event):
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)

func _ready():
	super._ready()
	_setup_level_select()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _setup_game_buttons():
	super._setup_game_buttons()
	if GameStateExample.has_game_state():
		%ContinueGameButton.show()
		if GameStateExample.get_max_level_reached() > 0:
			%LevelSelectButton.show()

func _on_continue_game_button_pressed():
	load_game_scene()

func _on_level_select_button_pressed():
	_open_sub_menu(level_select_scene)
