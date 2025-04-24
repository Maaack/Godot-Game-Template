class_name PauseMenu
extends OverlaidMenu

@export var options_packed_scene : PackedScene
@export_file("*.tscn") var main_menu_scene : String

var popup_open : Node

func close_popup() -> void:
	if popup_open != null:
		popup_open.hide()
		popup_open = null

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

func open_options_menu() -> void:
	var options_scene := options_packed_scene.instantiate()
	add_child(options_scene)
	_disable_focus.call_deferred()
	await options_scene.tree_exiting
	_enable_focus.call_deferred()

func _handle_cancel_input() -> void:
	if popup_open != null:
		close_popup()
	else:
		super._handle_cancel_input()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		%ExitButton.hide()

func _hide_options_if_unset() -> void:
	if options_packed_scene == null:
		%OptionsButton.hide()

func _hide_main_menu_if_unset() -> void:
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()

func _ready() -> void:
	_hide_exit_for_web()
	_hide_options_if_unset()
	_hide_main_menu_if_unset()

func _on_restart_button_pressed() -> void:
	%ConfirmRestart.popup_centered()
	popup_open = %ConfirmRestart

func _on_options_button_pressed() -> void:
	open_options_menu()

func _on_main_menu_button_pressed() -> void:
	%ConfirmMainMenu.popup_centered()
	popup_open = %ConfirmMainMenu

func _on_exit_button_pressed() -> void:
	%ConfirmExit.popup_centered()
	popup_open = %ConfirmExit

func _on_confirm_restart_confirmed() -> void:
	SceneLoader.reload_current_scene()
	close()

func _on_confirm_main_menu_confirmed() -> void:
	_load_scene(main_menu_scene)

func _on_confirm_exit_confirmed() -> void:
	get_tree().quit()
