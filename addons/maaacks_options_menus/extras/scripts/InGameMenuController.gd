class_name InGameMenuController
extends Node
## Interface for managing a single in-game menu at a time.
##
## This (static) class manages one in-game menu at a time.
## It can optionally safely pause and unpause the game for the menu.
## The scene_tree property must be set for the static methods to work.

static var current_menu : CanvasLayer
static var scene_tree : SceneTree
static var saved_mouse_mode : int
static var saved_focus_control

static func open_menu(menu_scene : PackedScene, viewport : Viewport, set_pause : bool = true) -> void:
	if scene_tree == null:
		push_error("scene_tree is null")
		return
	if is_instance_valid(current_menu):
		return
	saved_mouse_mode = Input.get_mouse_mode()
	saved_focus_control = viewport.gui_get_focus_owner()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	current_menu = menu_scene.instantiate()
	scene_tree.current_scene.call_deferred("add_child", current_menu)
	scene_tree.paused = set_pause

static func close_menu() -> void:
	if scene_tree == null:
		push_error("scene_tree is null")
		return
	if is_instance_valid(current_menu):
		current_menu.queue_free()
	Input.set_mouse_mode(saved_mouse_mode)
	scene_tree.paused = false
	if is_instance_valid(saved_focus_control) and saved_focus_control.is_inside_tree():
		saved_focus_control.grab_focus()
