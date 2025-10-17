@tool
extends OverlaidMenu

signal continue_pressed
signal main_menu_pressed

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _on_exit_button_pressed():
	$ConfirmExit.popup_centered()

func _on_main_menu_button_pressed():
	$ConfirmMainMenu.popup_centered()

func _on_confirm_main_menu_confirmed():
	main_menu_pressed.emit()
	close()

func _on_confirm_exit_confirmed():
	get_tree().quit()

func _on_close_button_pressed():
	continue_pressed.emit()
	close()
