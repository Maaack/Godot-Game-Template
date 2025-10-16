@tool
extends OverlaidMenu

signal continue_pressed
signal restart_pressed
signal main_menu_pressed

func _on_main_menu_button_pressed():
	$ConfirmMainMenu.popup_centered()

func _on_confirm_main_menu_confirmed():
	main_menu_pressed.emit()
	close()

func _on_restart_button_pressed():
	restart_pressed.emit()
	close()

func _on_close_button_pressed():
	continue_pressed.emit()
	close()
