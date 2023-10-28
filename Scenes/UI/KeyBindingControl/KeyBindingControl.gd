@tool
extends HBoxContainer

signal edit_button_pressed

@export var action_name: String = "Action": set = set_action_name
@export var keycode: int = 0: set = set_keycode

func set_action_name(value : String) -> void:
	action_name = value
	var node = get_node_or_null("ActionLabel")
	if node == null:
		return
	node.text = "%s :" % action_name

func set_keycode(value : int) -> void:
	keycode = value
	var node = get_node_or_null("AssignedKeyLabel")
	if node == null:
		return
	node.text = OS.get_keycode_string(keycode)
	
func _on_EditButton_pressed():
	emit_signal("edit_button_pressed")
