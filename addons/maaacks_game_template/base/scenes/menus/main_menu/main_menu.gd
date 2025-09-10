class_name MainMenu
extends Control

signal sub_menu_opened
signal sub_menu_closed
signal game_started
signal game_exited

## Defines the path to the game scene. Hides the play button if empty.
@export_file("*.tscn") var game_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene
@export_group("Extra Settings")
@export var signal_game_start : bool = false
@export var signal_game_exit : bool = false

var options_scene
var credits_scene
var sub_menu

@onready var menu_container = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var new_game_button = %NewGameButton
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button = %ExitButton
@onready var options_container = %OptionsContainer
@onready var credits_container = %CreditsContainer
@onready var flow_control_container = %FlowControlContainer
@onready var back_button = %BackButton

func load_game_scene() -> void:
	if signal_game_start:
		SceneLoader.load_scene(game_scene_path, true)
		game_started.emit()
	else:
		SceneLoader.load_scene(game_scene_path)

func new_game() -> void:
	load_game_scene()

func exit_game() -> void:
	if OS.has_feature("web"):
		return
	if signal_game_exit:
		game_exited.emit()
	else:
		get_tree().quit()

func _hide_menu() -> void:
	back_button.show()
	menu_container.hide()

func _show_menu() -> void:
	back_button.hide()
	menu_container.show()

func _open_sub_menu(menu : Control) -> void:
	sub_menu = menu
	sub_menu.show()
	_hide_menu()
	sub_menu_opened.emit()

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	_show_menu()
	sub_menu_closed.emit()

func _event_is_mouse_button_released(event : InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event : InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			exit_game()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		exit_button.hide()

func _hide_new_game_if_unset() -> void:
	if game_scene_path.is_empty():
		new_game_button.hide()

func _add_or_hide_options() -> void:
	if options_packed_scene == null:
		options_button.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		options_container.show()
		options_container.call_deferred("add_child", options_scene)

func _add_or_hide_credits() -> void:
	if credits_packed_scene == null:
		credits_button.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		credits_container.show()
		credits_container.call_deferred("add_child", credits_scene)

func _ready() -> void:
	flow_control_container.show()
	_hide_exit_for_web()
	_add_or_hide_options()
	_add_or_hide_credits()
	_hide_new_game_if_unset()

func _on_new_game_button_pressed() -> void:
	new_game()

func _on_options_button_pressed() -> void:
	_open_sub_menu(options_scene)

func _on_credits_button_pressed() -> void:
	_open_sub_menu(credits_scene)

func _on_exit_button_pressed() -> void:
	exit_game()

func _on_credits_end_reached() -> void:
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed() -> void:
	_close_sub_menu()
