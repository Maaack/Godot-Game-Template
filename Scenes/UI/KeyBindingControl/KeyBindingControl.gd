tool
extends HBoxContainer

signal edit_button_pressed

export(String) var action_name : String = "Action" setget set_action_name
export(int) var scancode : int = 0 setget set_scancode

func set_action_name(value : String) -> void:
	action_name = value
	var node = get_node_or_null("ActionLabel")
	if node == null:
		return
	node.text = "%s :" % action_name

func set_scancode(value : int) -> void:
	scancode = value
	var node = get_node_or_null("AssignedKeyLabel")
	if node == null:
		return
	node.text = OS.get_scancode_string(scancode)
	
func _on_EditButton_pressed():
	emit_signal("edit_button_pressed")
