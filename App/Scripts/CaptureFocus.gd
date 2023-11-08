extends Container

@export var search_depth : int = 1

func _focus_first(control_node : Control, levels : int = 1):
	if control_node == null or levels < 1:
		return false
	var children = control_node.get_children()
	for child in children:
		if child.focus_mode == FOCUS_ALL:
			child.grab_focus()
			return true
		if _focus_first(child, levels - 1):
			return true

func _check_visible_and_joypad():
	if is_visible_in_tree() and Input.get_connected_joypads().size() > 0:
		_focus_first(self, search_depth)

func _on_visibility_changed():
	call_deferred("_check_visible_and_joypad")

func _ready():
	if is_inside_tree():
		_check_visible_and_joypad()
		connect("visibility_changed", _on_visibility_changed)
