@tool
class_name PauseMenu
extends OverlaidWindow


@onready var restart_confirmation : Control = %RestartConfirmation
@onready var main_menu_confirmation : Control = %MainMenuConfirmation
@onready var exit_confirmation : Control = %ExitConfirmation

@export var options_menu_scene : PackedScene
@export_file("*.tscn") var main_menu_scene : String

var open_window : Node
var options_menu : Node

func close_window() -> void:
	if open_window != null:
		if open_window.has_method("close"):
			open_window.close()
		else:
			open_window.hide()
		open_window = null

func _disable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_NONE

func _enable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_ALL

func _load_scene(scene_path: String) -> void:
	_scene_tree.paused = false
	SceneLoader.load_scene(scene_path)

func _show_window(window : Control) -> void:
	_disable_focus.call_deferred()
	window.show()
	open_window = window
	await window.hidden
	_enable_focus.call_deferred()

func _handle_cancel_input() -> void:
	if open_window != null:
		close_window()
	else:
		super._handle_cancel_input()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		%ExitButton.hide()
	else:
		%ExitButton.show()

func _hide_options_if_unset() -> void:
	if options_menu_scene == null:
		%OptionsButton.hide()
	else:
		%OptionsButton.show()
		options_menu = options_menu_scene.instantiate()
		options_menu.visible = false
		add_child.call_deferred(options_menu)

func _hide_main_menu_if_unset() -> void:
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()
	else:
		%MainMenuButton.show()

func _ready() -> void:
	_hide_exit_for_web()
	_hide_options_if_unset()
	_hide_main_menu_if_unset()

func _on_restart_button_pressed() -> void:
	_show_window(restart_confirmation)

func _on_options_button_pressed() -> void:
	_show_window(options_menu)

func _on_main_menu_button_pressed() -> void:
	_show_window(main_menu_confirmation)

func _on_exit_button_pressed() -> void:
	_show_window(exit_confirmation)

func _on_restart_confirmation_confirmed() -> void:
	SceneLoader.reload_current_scene()
	close()

func _on_main_menu_confirmation_confirmed():
	_load_scene(main_menu_scene)

func _on_exit_confirmation_confirmed():
	get_tree().quit()
