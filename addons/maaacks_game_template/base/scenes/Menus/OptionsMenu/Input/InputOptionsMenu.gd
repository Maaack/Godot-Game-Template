extends Control

const ALREADY_ASSIGNED_TEXT : String = "%s already assigned to %s."
const ONE_INPUT_MINIMUM_TEXT : String = "%s must have at least one key or button assigned."
const KEY_DELETION_TEXT : String = "Are you sure you want to remove %s from %s?"

@export var action_name_map : Dictionary = {
	"move_up" : "Up",
	"move_down" : "Down",
	"move_left" : "Left",
	"move_right" : "Right",
	"interact" : "Interact"
}
@export var add_button_texture : Texture2D
@export var remove_button_texture : Texture2D

@onready var assignment_placeholder_text = $KeyAssignmentDialog.dialog_text
var tree_item_add_map : Dictionary = {}
var tree_item_remove_map : Dictionary = {}
var tree_item_action_map : Dictionary = {}
var assigned_input_events : Dictionary = {}
var editing_action_name : String = ""
var editing_item
var last_input_readable_name

func _popup_add_action_event(item : TreeItem) -> void:
	if item not in tree_item_add_map:
		return
	editing_item = item
	editing_action_name = tree_item_add_map[item]
	$KeyAssignmentDialog.title = "Assign Key for %s" % _get_action_readable_name(editing_action_name)
	$KeyAssignmentDialog.dialog_text = assignment_placeholder_text
	$KeyAssignmentDialog.get_ok_button().disabled = true
	$KeyAssignmentDialog.popup_centered()

func _popup_remove_action_event(item : TreeItem) -> void:
	if item not in tree_item_remove_map:
		return
	editing_item = item
	editing_action_name = tree_item_action_map[item]
	var readable_action_name = _get_action_readable_name(editing_action_name)
	$KeyDeletionDialog.title = "Remove Key for %s" % readable_action_name
	$KeyDeletionDialog.dialog_text = KEY_DELETION_TEXT % [item.get_text(0), readable_action_name]
	$KeyDeletionDialog.popup_centered()

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
	%Tree.clear()
	%Tree.create_item()

func _add_input_event_as_tree_item(action_name : String, input_event : InputEvent, parent_item : TreeItem):
	var input_tree_item : TreeItem = %Tree.create_item(parent_item)
	input_tree_item.set_text(0, InputEventHelper.get_text(input_event))
	if remove_button_texture != null:
		input_tree_item.add_button(0, remove_button_texture, -1, false, "Remove")
	tree_item_remove_map[input_tree_item] = input_event
	tree_item_action_map[input_tree_item] = action_name

func _add_action_as_tree_item(readable_name : String, action_name : String, input_events : Array[InputEvent]):
	var root_tree_item : TreeItem = %Tree.get_root()
	var action_tree_item : TreeItem = %Tree.create_item(root_tree_item)
	action_tree_item.set_text(0, readable_name)
	tree_item_add_map[action_tree_item] = action_name
	if add_button_texture != null:
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
		_add_action_as_tree_item(readable_name, action_name, input_events)

func _assign_input_event(input_event : InputEvent, action_name : String):
	assigned_input_events[InputEventHelper.get_text(input_event)] = action_name
		
func _assign_input_event_to_action(input_event : InputEvent, action_name : String) -> void:
	_assign_input_event(input_event, action_name)
	InputMap.action_add_event(action_name, input_event)
	var action_events = InputMap.action_get_events(action_name)
	AppSettings.set_config_input_events(action_name, action_events)
	_add_input_event_as_tree_item(action_name, input_event, editing_item)

func _can_remove_input_event(action_name : String) -> bool:
	return InputMap.action_get_events(action_name).size() > 1

func _remove_input_event(input_event : InputEvent):
	assigned_input_events.erase(InputEventHelper.get_text(input_event))

func _remove_input_event_from_action(input_event : InputEvent, action_name : String) -> void:
	_remove_input_event(input_event)
	AppSettings.remove_action_input_event(action_name, input_event)

func _build_assigned_input_events():
	assigned_input_events.clear()
	var action_names : Array[StringName] = AppSettings.get_filtered_action_names()
	for action_name in action_names:
		var input_events = InputMap.action_get_events(action_name)
		for input_event in input_events:
			_assign_input_event(input_event, action_name)

func _get_action_for_input_event(input_event : InputEvent) -> String:
	if InputEventHelper.get_text(input_event) in assigned_input_events:
		return assigned_input_events[InputEventHelper.get_text(input_event)] 
	return ""

func _horizontally_align_popup_labels():
	$KeyAssignmentDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$KeyDeletionDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$OneInputMinimumDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$AlreadyAssignedDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _ready():
	_build_assigned_input_events()
	_build_ui_tree()
	_horizontally_align_popup_labels()

func _add_action_event():
	var last_input_event = $KeyAssignmentDialog.last_input_event
	last_input_readable_name = $KeyAssignmentDialog.dialog_text
	if last_input_event != null:
		var assigned_action := _get_action_for_input_event(last_input_event)
		if not assigned_action.is_empty():
			var readable_action_name = _get_action_readable_name(assigned_action)
			$AlreadyAssignedDialog.dialog_text = ALREADY_ASSIGNED_TEXT % [last_input_readable_name, readable_action_name]
			$AlreadyAssignedDialog.popup_centered()
		else:
			_assign_input_event_to_action(last_input_event, editing_action_name)
	editing_action_name = ""

func _on_key_assignment_dialog_canceled():
	editing_action_name = ""

func _remove_action_event(item : TreeItem):
	if item not in tree_item_remove_map:
		return
	var action_name = tree_item_action_map[item]
	var input_event = tree_item_remove_map[item]
	if not _can_remove_input_event(action_name):
		var readable_action_name = _get_action_readable_name(action_name)
		$OneInputMinimumDialog.dialog_text = ONE_INPUT_MINIMUM_TEXT % readable_action_name
		$OneInputMinimumDialog.popup_centered()
		return
	_remove_input_event_from_action(input_event, action_name)
	var parent_tree_item = item.get_parent()
	parent_tree_item.remove_child(item)

func _check_item_actions(item):
	if item in tree_item_add_map:
		_popup_add_action_event(item)
	elif item in tree_item_remove_map:
		_popup_remove_action_event(item)

func _on_tree_button_clicked(item, _column, _id, _mouse_button_index):
	_check_item_actions(item)

func _on_reset_button_pressed():
	AppSettings.reset_to_default_inputs()
	_build_assigned_input_events()
	_build_ui_tree()

func _on_tree_item_activated():
	var item = %Tree.get_selected()
	_check_item_actions(item)

func _on_key_deletion_dialog_confirmed():
	if is_instance_valid(editing_item):
		_remove_action_event(editing_item)

func _on_key_assignment_dialog_confirmed():
	_add_action_event()
