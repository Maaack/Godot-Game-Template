extends CanvasLayer

@export_file("*.tscn") var next_scene : String
@export_file("*.tscn") var main_menu_scene : String

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $ConfirmExit.visible:
			$ConfirmExit.hide()
		elif $ConfirmMainMenu.visible:
			$ConfirmMainMenu.hide()
		get_viewport().set_input_as_handled()

func _setup_continue():
	if next_scene.is_empty():
		%ContinueButton.hide()

func _setup_main_menu():
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()
	_setup_continue()
	_setup_main_menu()
	InGameMenuController.scene_tree = get_tree()

func _on_exit_button_pressed():
	$ConfirmExit.popup_centered()

func _on_main_menu_button_pressed():
	$ConfirmMainMenu.popup_centered()

func _on_continue_button_pressed():
	SceneLoader.load_scene(next_scene)
	InGameMenuController.close_menu()

func _on_confirm_main_menu_confirmed():
	SceneLoader.load_scene(main_menu_scene)
	InGameMenuController.close_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_confirm_exit_confirmed():
	get_tree().quit()
