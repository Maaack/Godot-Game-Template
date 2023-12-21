extends Node
class_name InGameMenuController

static var current_menu : CanvasLayer
static var saved_mouse_mode : int
static var saved_focus_control

static func open_menu_from_node(menu_scene : PackedScene, node : Node, set_pause : bool = true) -> void:
	open_menu(menu_scene, node.get_viewport(), node.get_tree(), set_pause)

static func close_menu_from_node(node : Node) -> void:
	close_menu(node.get_tree())

static func open_menu(menu_scene : PackedScene, viewport : Viewport, scene_tree: SceneTree, set_pause : bool = true) -> void:
	if is_instance_valid(current_menu):
		return
	saved_mouse_mode = Input.get_mouse_mode()
	saved_focus_control = viewport.gui_get_focus_owner()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	current_menu = menu_scene.instantiate()
	scene_tree.current_scene.call_deferred("add_child", current_menu)
	scene_tree.paused = set_pause

static func close_menu(scene_tree: SceneTree) -> void:
	if is_instance_valid(current_menu):
		current_menu.queue_free()
	Input.set_mouse_mode(saved_mouse_mode)
	scene_tree.paused = false
	if is_instance_valid(saved_focus_control):
		saved_focus_control.grab_focus()
