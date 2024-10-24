extends CanvasLayer

signal continue_pressed
signal restart_pressed

@export_file("*.tscn") var main_menu_scene : String

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $ConfirmMainMenu.visible:
			$ConfirmMainMenu.hide()
		get_viewport().set_input_as_handled()

func _setup_main_menu():
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()

func _ready():
	_setup_main_menu()
	InGameMenuController.scene_tree = get_tree()

func _on_main_menu_button_pressed():
	$ConfirmMainMenu.popup_centered()

func _on_continue_button_pressed():
	continue_pressed.emit()
	InGameMenuController.close_menu()

func _on_confirm_main_menu_confirmed():
	SceneLoader.load_scene(main_menu_scene)
	InGameMenuController.close_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed():
	restart_pressed.emit()
	InGameMenuController.close_menu()
