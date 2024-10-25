extends CanvasLayer

signal continue_pressed
signal main_menu_pressed

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $ConfirmExit.visible:
			$ConfirmExit.hide()
		elif $ConfirmMainMenu.visible:
			$ConfirmMainMenu.hide()
		get_viewport().set_input_as_handled()

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _on_exit_button_pressed():
	$ConfirmExit.popup_centered()

func _on_main_menu_button_pressed():
	$ConfirmMainMenu.popup_centered()

func _on_continue_button_pressed():
	continue_pressed.emit()

func _on_confirm_main_menu_confirmed():
	main_menu_pressed.emit()

func _on_confirm_exit_confirmed():
	get_tree().quit()
