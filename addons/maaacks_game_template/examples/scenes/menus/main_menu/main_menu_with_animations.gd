extends MainMenu

@export var level_select_packed_scene: PackedScene
@export var confirm_new_game : bool = true

var level_select_scene : Node
var animation_state_machine : AnimationNodeStateMachinePlayback

@onready var continue_game_button = %ContinueGameButton
@onready var level_select_button = %LevelSelectButton
@onready var level_select_container = %LevelSelectContainer

func load_game_scene() -> void:
	GameStateExample.start_game()
	super.load_game_scene()

func new_game() -> void:
	if confirm_new_game and GameStateExample.has_game_state():
		%NewGameConfirmationDialog.popup_centered()
	else:
		GameStateExample.reset()
		load_game_scene()

func intro_done() -> void:
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro() -> bool:
	return animation_state_machine.get_current_node() == "Intro"

func _event_skips_intro(event : InputEvent) -> bool:
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu : Node) -> void:
	super._open_sub_menu(menu)
	animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu() -> void:
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

func _input(event : InputEvent) -> void:
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)

func _add_level_select_if_set() -> void: 
	if level_select_packed_scene == null: return
	if GameStateExample.get_levels_reached() <= 1 : return
	level_select_scene = level_select_packed_scene.instantiate()
	level_select_scene.hide()
	level_select_container.show()
	level_select_container.call_deferred("add_child", level_select_scene)
	if level_select_scene.has_signal("level_selected"):
		level_select_scene.connect("level_selected", load_game_scene)
	level_select_button.show()

func _show_continue_if_set() -> void:
	if GameStateExample.has_game_state():
		continue_game_button.show()

func _ready() -> void:
	super._ready()
	_add_level_select_if_set()
	_show_continue_if_set()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _on_continue_game_button_pressed() -> void:
	GameStateExample.continue_game()
	load_game_scene()

func _on_level_select_button_pressed() -> void:
	_open_sub_menu(level_select_scene)

func _on_new_game_confirmation_dialog_confirmed():
	GameStateExample.reset()
	load_game_scene()
