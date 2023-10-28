extends Control

@onready var placeholder_text = $KeyAssignmentDialog.dialog_text
var key_binding_control_scene = preload("res://Scenes/UI/KeyBindingControl/KeyBindingControl.tscn")
var input_node_map : Dictionary = {}
var editing_action_name : String = ""
var last_input_event : InputEventWithModifiers

func _edit_key(action_name : String) -> void:
	editing_action_name = action_name
	$KeyAssignmentDialog.title = AppSettings.INPUT_MAP[action_name]
	$KeyAssignmentDialog.dialog_text = placeholder_text
	$KeyAssignmentDialog.get_ok_button().disabled = true
	$KeyAssignmentDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$KeyAssignmentDialog.popup_centered()

func _update_ui():
	for action_name in AppSettings.INPUT_MAP.keys():
		var input_events = InputMap.action_get_events(action_name)
		if input_events.size() < 1:
			print("%s is empty" % action_name)
			continue
		var input_event = input_events[0]
		var readable_name = AppSettings.INPUT_MAP[action_name]
		var control_instance
		if not action_name in input_node_map:
			control_instance = key_binding_control_scene.instantiate()
			control_instance.action_name = readable_name
			control_instance.connect("edit_button_pressed", Callable(self, "_edit_key").bind(action_name))
			input_node_map[action_name] = control_instance
			$VBoxContainer.add_child(control_instance)
		else:
			control_instance = input_node_map[action_name]
		control_instance.keycode = AppSettings.get_input_event_scancode(input_event)

func _assign_key_to_action(action_event : InputEventKey, action_name : String) -> void:
	for old_event in InputMap.action_get_events(action_name):
		InputMap.action_erase_event(action_name, old_event)
	InputMap.action_add_event(action_name, action_event)
	AppSettings.set_action_scancode(action_name, AppSettings.get_input_event_scancode(action_event))
	_update_ui()

func _ready():
	AppSettings.set_inputs_from_config()
	_update_ui()


func _on_KeyAssignmentDialog_confirmed():
	if $KeyAssignmentDialog.last_input_event != null:
		_assign_key_to_action($KeyAssignmentDialog.last_input_event, editing_action_name)
	editing_action_name = ""

func _on_key_assignment_dialog_canceled():
	editing_action_name = ""
