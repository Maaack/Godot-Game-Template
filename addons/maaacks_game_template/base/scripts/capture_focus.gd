class_name CaptureFocus
extends Container
## Node that captures UI focus for games with a hidden mouse or joypad enabled.
##
## This script assists with capturing UI focus when
## opening, closing, or switching between menus.
## When attached to a node, it will check if it was changed to visible
## and if it should grab focus. If both are true, it will capture focus
## on the first eligible node in its scene tree.

## Hierarchical depth to search in the scene tree.
@export var search_depth : int = 1
@export var enabled : bool = false
@export var joypad_enabled : bool = true
@export var mouse_hidden_enabled : bool = true

## Locks focus
@export var lock : bool = false :
	set(value):
		var value_changed : bool = lock != value
		lock = value
		if value_changed and not lock:
			update_focus()

func _focus_first_search(control_node : Control, levels : int = 1):
	if control_node == null or !control_node.is_visible_in_tree():
		return false
	if control_node.focus_mode == FOCUS_ALL:
		control_node.grab_focus()
		return true
	if levels < 1:
		return false
	var children = control_node.get_children()
	for child in children:
		if _focus_first_search(child, levels - 1):
			return true

func focus_first():
	_focus_first_search(self, search_depth)

func update_focus():
	if lock : return
	if _is_visible_and_should_capture():
		focus_first()

func _should_capture_focus():
	return enabled or \
	(Input.get_connected_joypads().size() > 0 and joypad_enabled) or \
	(Input.mouse_mode not in [Input.MOUSE_MODE_VISIBLE, Input.MOUSE_MODE_CONFINED] and mouse_hidden_enabled)

func _is_visible_and_should_capture():
	return is_visible_in_tree() and _should_capture_focus()

func _on_visibility_changed():
	call_deferred("update_focus")

func _ready():
	if is_inside_tree():
		update_focus()
		connect("visibility_changed", _on_visibility_changed)
