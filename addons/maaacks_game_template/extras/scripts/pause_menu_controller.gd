class_name PauseMenuController
extends Node

## Node for opening a pause menu when detecting a 'ui_cancel' event.

@export var pause_menu_packed : PackedScene

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var current_menu = pause_menu_packed.instantiate()
		get_tree().current_scene.call_deferred("add_child", current_menu)
