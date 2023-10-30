extends Control

@export var action_name_map : Dictionary = {}
@export var add_button_texture : Texture2D
@export var remove_button_texture : Texture2D

@onready var placeholder_text = $KeyAssignmentDialog.dialog_text
var input_node_map : Dictionary = {}
var last_input_event : InputEventWithModifiers
var tree_item_add_map : Dictionary = {}
var tree_item_remove_map : Dictionary = {}
var tree_item_action_map : Dictionary = {}
var editing_action_name : String = ""
var editing_item

func _popup_add_action_event(item : TreeItem) -> void:
	if item not in tree_item_add_map:
		return
	editing_item = item
	editing_action_name = tree_item_add_map[item]
	$KeyAssignmentDialog.title = _get_action_readable_name(editing_action_name)
	$KeyAssignmentDialog.dialog_text = placeholder_text
	$KeyAssignmentDialog.get_ok_button().disabled = true
	$KeyAssignmentDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$KeyAssignmentDialog.popup_centered()

func _get_action_keycode(action_event : InputEvent):
	if action_event is InputEventMouse:
		return 0
	if action_event.keycode != 0:
		return action_event.get_keycode_with_modifiers()
	else:
		return action_event.get_physical_keycode_with_modifiers()

func _update_action_name_map():
	var action_names : Array[StringName] = AppSettings.get_filtered_action_names()
	for action_name in action_names:
		var readable_name : String = action_name
		if not readable_name in action_name_map:
			action_name_map[readable_name] = readable_name

func _start_tree():
	%Tree.create_item()

func _add_input_event_as_tree_item(action_name : String, input_event : InputEvent, parent_item : TreeItem):
	var input_tree_item : TreeItem = %Tree.create_item(parent_item)
	input_tree_item.set_text(0, input_event.as_text())
	input_tree_item.add_button(0, remove_button_texture, -1, false, "Remove")
	tree_item_remove_map[input_tree_item] = input_event
	tree_item_action_map[input_tree_item] = action_name

func _add_tree_item(action_name : String, input_events : Array[InputEvent]):
	var root_tree_item : TreeItem = %Tree.get_root()
	var action_tree_item : TreeItem = %Tree.create_item(root_tree_item)
	action_tree_item.set_text(0, action_name)
	tree_item_add_map[action_tree_item] = action_name
	action_tree_item.add_button(0, add_button_texture, -1, false, "Add")
	for input_event in input_events:
		_add_input_event_as_tree_item(action_name, input_event, action_tree_item)

func _get_action_readable_name(action_name : StringName) -> String:
	var readable_name : String = action_name
	if readable_name in action_name_map:
		readable_name = action_name_map[readable_name]
	else:
		action_name_map[readable_name] = readable_name
	return readable_name

func _build_ui_tree():
	_start_tree()
	var action_names : Array[StringName] = AppSettings.get_filtered_action_names()
	for action_name in action_names:
		var input_events = InputMap.action_get_events(action_name)
		if input_events.size() < 1:
			print("%s is empty" % action_name)
			continue
		var readable_name : String = _get_action_readable_name(action_name)
		_add_tree_item(readable_name, input_events)

func _assign_key_to_action(input_event : InputEvent, action_name : String) -> void:
	InputMap.action_add_event(action_name, input_event)
	var action_events = InputMap.action_get_events(action_name)
	AppSettings.set_config_input_events(action_name, action_events)
	_add_input_event_as_tree_item(action_name, input_event, editing_item)

func _ready():
	_build_ui_tree()

func _on_KeyAssignmentDialog_confirmed():
	if $KeyAssignmentDialog.last_input_event != null:
		_assign_key_to_action($KeyAssignmentDialog.last_input_event, editing_action_name)
		
	editing_action_name = ""

func _on_key_assignment_dialog_canceled():
	editing_action_name = ""

func _remove_action_event(item : TreeItem):
	if item not in tree_item_remove_map:
		return
	var action_name = tree_item_action_map[item]
	var input_event = tree_item_remove_map[item]
	if InputMap.action_get_events(action_name).size() <= 1:
		$OneInputMinimumDialog.popup_centered()
		return 
	AppSettings.remove_action_input_event(action_name, input_event)
	var parent_tree_item = item.get_parent()
	parent_tree_item.remove_child(item)

func _on_tree_button_clicked(item, column, id, mouse_button_index):
	if item in tree_item_add_map:
		_popup_add_action_event(item)
	elif item in tree_item_remove_map:
		_remove_action_event(item)

func _on_reset_button_pressed():
	AppSettings.reset_to_default_inputs()
	%Tree.clear()
	_build_ui_tree()
