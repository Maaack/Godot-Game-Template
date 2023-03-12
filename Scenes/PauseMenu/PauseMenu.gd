extends CanvasLayer

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $Control/ConfirmExit.visible:
			$Control/ConfirmExit.hide()
		elif $Control/ConfirmMainMenu.visible:
			$Control/ConfirmMainMenu.hide()
		elif $Control/OptionsMenu.visible:
			$Control/OptionsMenu.visible = false
			$Control/ButtonsContainer.visible = true
		else:
			InGameMenuController.close_menu()


func _on_ResumeBtn_pressed():
	InGameMenuController.close_menu()

func _on_RestartBtn_pressed():
	$Control/ConfirmRestart.popup_centered()

func _on_OptionsBtn_pressed():
	$Control/ButtonsContainer.visible = false
	$Control/OptionsMenu.visible = true

func _on_MainMenuBtn_pressed():
	$Control/ConfirmMainMenu.popup_centered()

func _on_ExitBtn_pressed():
	$Control/ConfirmExit.popup_centered()

func _on_ConfirmRestart_confirmed():
	SceneLoader.reload_current_scene()

func _on_ConfirmMainMenu_confirmed():
	InGameMenuController.close_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_ConfirmExit_confirmed():
	get_tree().quit()

func _ready():
	if OS.has_feature("web"):
		$Control/ButtonsContainer/ExitBtn.hide()
