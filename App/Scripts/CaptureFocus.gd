extends Container

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
