class_name CaptureFocus
extends Container
## Node that captures UI focus for joypad users.
##
## This script assists with capturing UI focus for joypad users when
## opening, closing, or switching between menus.
## When attached to a node, it will check if it was changed to visible
## and a joypad is being used. If both are true, it will capture focus
## on the first eligible node in its scene tree.

## Hierarchical depth to search in the scene tree.
@export var search_depth : int = 1

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

func _check_visible_and_joypad():
	if is_visible_in_tree() and Input.get_connected_joypads().size() > 0:
		focus_first()

func _on_visibility_changed():
	call_deferred("_check_visible_and_joypad")

func _ready():
	if is_inside_tree():
		_check_visible_and_joypad()
		connect("visibility_changed", _on_visibility_changed)
