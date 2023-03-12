extends Control

var pause_menu_packed = preload("res://Scenes/PauseMenu/PauseMenu.tscn")

var can_pause = true # to prevent from instantly repausing after unpaused from the pause menu by pressing ui_cancel

func _gui_input(event):
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_cancel") and can_pause:
		can_pause = false
		InGameMenuController.open_menu(pause_menu_packed)
	else:
		can_pause = true
