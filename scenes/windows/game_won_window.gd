@tool
extends OverlaidWindow

signal continue_pressed
signal main_menu_pressed

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _on_exit_button_pressed():
	%ExitConfirmation.show()

func _on_main_menu_button_pressed():
	%MainMenuConfirmation.show()

func _on_close_button_pressed():
	continue_pressed.emit()
	close()

func _on_main_menu_confirmation_confirmed():
	main_menu_pressed.emit()
	close()

func _on_exit_confirmation_confirmed():
	get_tree().quit()
