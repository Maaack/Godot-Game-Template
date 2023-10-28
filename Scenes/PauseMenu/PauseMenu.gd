extends CanvasLayer

@export_file("*.tscn") var main_menu_scene : String
var popup_open

func close_popup():
	if popup_open != null and popup_open.visible:
		popup_open.hide()
		popup_open == null

func close_options_menu():
	%SubMenuContainer.hide()
	%MenuButtons.show()

func open_options_menu():
	%SubMenuContainer.show()
	%MenuButtons.hide()

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		if popup_open == null:
			InGameMenuController.close_menu()
		else:
			close_popup()
			close_options_menu()

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()

func _on_resume_button_pressed():
	InGameMenuController.close_menu()

func _on_restart_button_pressed():
	%ConfirmRestart.popup_centered()

func _on_options_button_pressed():
	open_options_menu()

func _on_main_menu_button_pressed():
	%ConfirmMainMenu.popup_centered()

func _on_exit_button_pressed():
	%ConfirmExit.popup_centered()

func _on_confirm_restart_confirmed():
	SceneLoader.reload_current_scene()

func _on_confirm_main_menu_confirmed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SceneLoader.load_scene(main_menu_scene)
	InGameMenuController.close_menu()

func _on_confirm_exit_confirmed():
	get_tree().quit()

func _on_back_button_pressed():
	close_options_menu()
