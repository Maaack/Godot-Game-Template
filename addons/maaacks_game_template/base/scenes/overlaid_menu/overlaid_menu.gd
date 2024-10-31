@tool
class_name OverlaidMenu
extends Control

@export var pauses_game : bool = false :
	set(value):
		pauses_game = value
		if pauses_game:
			process_mode = PROCESS_MODE_ALWAYS
		else:
			process_mode = PROCESS_MODE_INHERIT

var _initial_pause_state : bool = false
var _initial_focus_mode : FocusMode = FOCUS_ALL
var _initial_mouse_mode : int
var _initial_focus_control
var _scene_tree : SceneTree 

func close():
	_scene_tree.paused = _initial_pause_state
	Input.set_mouse_mode(_initial_mouse_mode)
	if is_instance_valid(_initial_focus_control) and _initial_focus_control.is_inside_tree():
		_initial_focus_control.focus_mode = _initial_focus_mode
		_initial_focus_control.grab_focus()
	queue_free()

func _handle_cancel_input():
	close()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_handle_cancel_input()
		get_viewport().set_input_as_handled()

func _on_close_button_pressed():
	close()

func _enter_tree():
	_initial_focus_control = get_viewport().gui_get_focus_owner()
	_initial_mouse_mode = Input.get_mouse_mode()
	_scene_tree = get_tree()
	_initial_pause_state = _scene_tree.paused
	if not Engine.is_editor_hint():
		_scene_tree.paused = pauses_game or _initial_pause_state
	if _initial_focus_control:
		_initial_focus_mode = _initial_focus_control.focus_mode
