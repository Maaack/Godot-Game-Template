class_name PauseMenu
extends OverlaidMenu

@export var options_packed_scene : PackedScene
@export_file("*.tscn") var main_menu_scene : String

var popup_open

func close_popup():
	if popup_open != null:
		popup_open.hide()
		popup_open = null

func _disable_focus():
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_NONE

func _enable_focus():
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_ALL

func open_options_menu():
	var options_scene = options_packed_scene.instantiate()
	add_child(options_scene)
	_disable_focus.call_deferred()
	await options_scene.tree_exiting
	_enable_focus.call_deferred()

func _handle_cancel_input():
	if popup_open != null:
		close_popup()
	else:
		super._handle_cancel_input()

func _setup_options():
	if options_packed_scene == null:
		%OptionsButton.hide()

func _setup_main_menu():
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()
	_setup_options()
	_setup_main_menu()

func _on_restart_button_pressed():
	%ConfirmRestart.popup_centered()
	popup_open = %ConfirmRestart

func _on_options_button_pressed():
	open_options_menu()

func _on_main_menu_button_pressed():
	%ConfirmMainMenu.popup_centered()
	popup_open = %ConfirmMainMenu

func _on_exit_button_pressed():
	%ConfirmExit.popup_centered()
	popup_open = %ConfirmExit

func _on_confirm_restart_confirmed():
	SceneLoader.reload_current_scene()
	close()

func _on_confirm_main_menu_confirmed():
	SceneLoader.load_scene(main_menu_scene)
	close()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_confirm_exit_confirmed():
	get_tree().quit()
