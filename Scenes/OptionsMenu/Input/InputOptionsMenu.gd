extends Control

onready var placeholder_text = $KeyAssignmentDialog.dialog_text
var key_binding_control_scene = preload("res://Scenes/UI/KeyBindingControl/KeyBindingControl.tscn")
var input_node_map : Dictionary = {}
var editing_action_name : String = ""
var last_input_event : InputEventWithModifiers

func is_editing_key_binding():
	return editing_action_name != "" 

func _edit_key(action_name : String) -> void:
	editing_action_name = action_name
	$KeyAssignmentDialog.window_title = AppSettings.INPUT_MAP[action_name]
	$KeyAssignmentDialog.dialog_text = placeholder_text
	$KeyAssignmentDialog.get_ok().disabled = true
	$KeyAssignmentDialog.get_label().align = Label.ALIGN_CENTER
	$KeyAssignmentDialog.popup_centered()

func _update_ui():
	for action_name in AppSettings.INPUT_MAP.keys():
		var input_events = InputMap.get_action_list(action_name)
		if input_events.size() < 1:
			print("%s is empty" % action_name)
			continue
		var input_event = input_events[0]
		var readable_name = AppSettings.INPUT_MAP[action_name]
		var control_instance
		if not action_name in input_node_map:
			control_instance = key_binding_control_scene.instance()
			control_instance.action_name = readable_name
			control_instance.connect("edit_button_pressed", self, "_edit_key", [action_name])
			input_node_map[action_name] = control_instance
			$VBoxContainer.add_child(control_instance)
		else:
			control_instance = input_node_map[action_name]
		control_instance.scancode = AppSettings.get_input_event_scancode(input_event)

func _assign_key_to_action(action_event : InputEventKey, action_name : String) -> void:
	for old_event in InputMap.get_action_list(action_name):
		InputMap.action_erase_event(action_name, old_event)
	InputMap.action_add_event(action_name, action_event)
	AppSettings.set_action_scancode(action_name, AppSettings.get_input_event_scancode(action_event))
	_update_ui()

func _ready():
	AppSettings.set_inputs_from_config()
	_update_ui()

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
