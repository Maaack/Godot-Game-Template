extends Control

const INPUT_SECTION = 'InputSettings'

export(Dictionary) var input_map : Dictionary = {
	"move_forward" : "Forward",
	"move_backward" : "Backward",
	"move_left" : "Left",
	"move_right" : "Right",
	"run" : "Run",
	"jump" : "Jump",
	"interact" : "Interact",
}

onready var placeholder_text = $KeyAssignmentDialog.dialog_text
var key_binding_control_scene = preload("res://Scenes/UI/KeyBindingControl/KeyBindingControl.tscn")
var input_node_map : Dictionary = {}
var editing_action_name : String = ""
var last_input_event : InputEventWithModifiers

func is_editing_key_binding():
	return editing_action_name != "" 

func _get_action_scancode(action_event : InputEventKey) -> int:
	if action_event.scancode != 0:
		return action_event.get_scancode_with_modifiers()
	else:
		return OS.keyboard_get_scancode_from_physical(action_event.get_physical_scancode_with_modifiers())

func _edit_key(action_name : String) -> void:
	editing_action_name = action_name
	$KeyAssignmentDialog.window_title = input_map[action_name]
	$KeyAssignmentDialog.dialog_text = placeholder_text
	$KeyAssignmentDialog.get_ok().disabled = true
	$KeyAssignmentDialog.get_label().align = Label.ALIGN_CENTER
	$KeyAssignmentDialog.popup_centered()

func _update_ui():
	for action_name in input_map.keys():
		var input_events = InputMap.get_action_list(action_name)
		if input_events.size() < 1:
			print("%s is empty" % action_name)
			continue
		var input_event = input_events[0]
		var readable_name = input_map[action_name]
		var control_instance
		if not action_name in input_node_map:
			control_instance = key_binding_control_scene.instance()
			control_instance.action_name = readable_name
			control_instance.connect("edit_button_pressed", self, "_edit_key", [action_name])
			input_node_map[action_name] = control_instance
			$VBoxContainer.add_child(control_instance)
		else:
			control_instance = input_node_map[action_name]
		control_instance.scancode = _get_action_scancode(input_event)

func _assign_key_to_action(action_event : InputEventKey, action_name : String) -> void:
	for old_event in InputMap.get_action_list(action_name):
		InputMap.action_erase_event(action_name, old_event)
	InputMap.action_add_event(action_name, action_event)
	Config.set_config(INPUT_SECTION, action_name, _get_action_scancode(action_event))
	_update_ui()

func _set_init_config_if_empty() -> void:
	if Config.has_section(INPUT_SECTION):
		return
	for action_name in input_map.keys():
		var action_events : Array = InputMap.get_action_list(action_name)
		if action_events.size() == 0:
			continue
		var action_event : InputEventWithModifiers = action_events[0]
		if action_event is InputEventKey:
			Config.set_config(INPUT_SECTION, action_name, _get_action_scancode(action_event))

func _set_inputs_from_config():
	_set_init_config_if_empty()
	for action_name in Config.get_section_keys(INPUT_SECTION):
		var scancode = Config.get_config(INPUT_SECTION, action_name)
		var event = InputEventKey.new()
		event.scancode = scancode
		for old_event in InputMap.get_action_list(action_name):
			if old_event is InputEventKey:
				InputMap.action_erase_event(action_name, old_event)
		InputMap.action_add_event(action_name, event)

func _sync_with_config() -> void:
	_set_init_config_if_empty()
	_set_inputs_from_config()
	_update_ui()

func _ready():
	_sync_with_config()
	$KeyAssignmentDialog.get_ok().focus_mode = FOCUS_NONE
	$KeyAssignmentDialog.get_cancel().focus_mode = FOCUS_NONE

func _input(event):
	if not event.is_pressed() or not is_editing_key_binding():
		return
	if event is InputEventKey:
		last_input_event = event
		$KeyAssignmentDialog.dialog_text = OS.get_scancode_string(event.get_scancode_with_modifiers())
		$KeyAssignmentDialog.get_ok().disabled = false

func _on_KeyAssignmentDialog_confirmed():
	_assign_key_to_action(last_input_event, editing_action_name)
	editing_action_name = ""
