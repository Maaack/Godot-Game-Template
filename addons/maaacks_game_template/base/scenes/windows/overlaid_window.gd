@tool
class_name OverlaidWindow
extends WindowContainer

@export var pauses_game : bool = false :
	set(value):
		pauses_game = value
		if pauses_game:
			process_mode = PROCESS_MODE_ALWAYS
		else:
			process_mode = PROCESS_MODE_INHERIT
@export var makes_mouse_visible : bool = true
@export var exclusive : bool = true

var _initial_pause_state : bool = false
var _initial_focus_mode : FocusMode = FOCUS_ALL
var _initial_mouse_mode : Input.MouseMode
var _initial_focus_control
var _scene_tree : SceneTree 
var _exclusive_control_node : Node

func close() -> void:
	_scene_tree.paused = _initial_pause_state
	Input.set_mouse_mode(_initial_mouse_mode)
	if is_instance_valid(_initial_focus_control) and _initial_focus_control.is_inside_tree():
		_initial_focus_control.focus_mode = _initial_focus_mode
		_initial_focus_control.grab_focus()
	if _exclusive_control_node:
		_exclusive_control_node.queue_free()
	super.close()

func _handle_cancel_input() -> void:
	close()

func _unhandled_input(event : InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_handle_cancel_input()
		get_viewport().set_input_as_handled()

func _on_close_button_pressed() -> void:
	close()

func _overlaid_window_setup():
	_initial_pause_state = _scene_tree.paused
	_initial_mouse_mode = Input.get_mouse_mode()
	_initial_focus_control = get_viewport().gui_get_focus_owner()
	if _initial_focus_control:
		_initial_focus_mode = _initial_focus_control.focus_mode
		_initial_focus_control.release_focus()
	if Engine.is_editor_hint(): return
	_scene_tree.paused = pauses_game or _initial_pause_state
	if makes_mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if exclusive:
		_exclusive_control_node = Control.new()
		_exclusive_control_node.set_anchors_preset(PRESET_FULL_RECT)
		add_sibling.call_deferred(_exclusive_control_node)
		await _exclusive_control_node.draw
		get_parent().move_child(_exclusive_control_node, get_index())

func _on_visibility_changed() -> void:
	if visible:
		_overlaid_window_setup()

func _enter_tree() -> void:
	_scene_tree = get_tree()
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()
