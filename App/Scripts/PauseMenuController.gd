extends Node

@export var pause_menu_packed : PackedScene

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		InGameMenuController.open_menu_from_node(pause_menu_packed, self)
