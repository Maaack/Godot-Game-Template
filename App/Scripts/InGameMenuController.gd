extends Node

var current_menu : CanvasLayer
var saved_mouse_mode : int
var saved_focus_control

func open_menu(menu_scene : PackedScene, set_pause : bool = true) -> void:
	if is_instance_valid(current_menu):
		return
	saved_mouse_mode = Input.get_mouse_mode()
	saved_focus_control = get_viewport().gui_get_focus_owner()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	current_menu = menu_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", current_menu)
	get_tree().paused = set_pause

func close_menu() -> void:
	if is_instance_valid(current_menu):
		current_menu.queue_free()
	Input.set_mouse_mode(saved_mouse_mode)
	get_tree().paused = false
	if is_instance_valid(saved_focus_control):
		saved_focus_control.grab_focus()
