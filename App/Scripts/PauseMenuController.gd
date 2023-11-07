extends Node

@export var pause_menu_packed : PackedScene

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		InGameMenuController.open_menu(pause_menu_packed)
