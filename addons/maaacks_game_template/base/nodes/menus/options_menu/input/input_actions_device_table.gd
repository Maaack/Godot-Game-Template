@tool
class_name InputActionsDeviceTable
extends InputActionsTable
## Scene to list the input actions out as buttons by input type (keyboard, mouse, gamepad).

const ANY_DEVICE = "Any"
const KEYBOARD_AND_MOUSE_DEVICE = "Keyboard & Mouse"
const KEYBOARD_DEVICE =  "Keyboard"
const MOUSE_DEVICE = "Mouse"
const JOYPAD_DEVICE = "Gamepad"

const INPUT_HELPER_DEVICE_NAME_ENUMS_MAP : Dictionary[StringName, Array] = {
	InputEventHelper.DEVICE_KEYBOARD : [2, 1, 0],
	InputEventHelper.DEVICE_MOUSE : [3, 1, 0],
	InputEventHelper.DEVICE_JOYPAD : [4, 0],
	InputEventHelper.DEVICE_SCREEN : []
}

const ENUM_INPUT_HELPER_DEVICE_NAME : Dictionary[int, String] = {
	0 : ANY_DEVICE,
	1 : KEYBOARD_AND_MOUSE_DEVICE,
	2 : KEYBOARD_DEVICE,
	3 : MOUSE_DEVICE,
	4 : JOYPAD_DEVICE,
}

const ENUM_INPUT_HELPER_DEVICE_NAMES_MAP : Dictionary[int, Array] = {
	0 : [],
	1 : [InputEventHelper.DEVICE_KEYBOARD, InputEventHelper.DEVICE_MOUSE],
	2 : [InputEventHelper.DEVICE_KEYBOARD],
	3 : [InputEventHelper.DEVICE_MOUSE],
	4 : [InputEventHelper.DEVICE_JOYPAD],
}

@export_enum(ANY_DEVICE, KEYBOARD_AND_MOUSE_DEVICE, KEYBOARD_DEVICE, MOUSE_DEVICE, JOYPAD_DEVICE) var action_group_input_devices : Array[int] :
	set(value):
		var _value_changed = action_group_input_devices != value
		action_group_input_devices = value
		if _value_changed:
			_refresh_action_group_names()

func _refresh_action_group_names() -> void:
	action_groups = action_group_input_devices.size()
	action_group_names.clear()
	for input_device_enum in action_group_input_devices:
		var group_name := ENUM_INPUT_HELPER_DEVICE_NAME[input_device_enum]
		action_group_names.append(group_name)

func _get_event_matching_enum(input_event : InputEvent, sub_action_groups_input_devices:Array[int]) -> int:
	var device_name := InputEventHelper.get_input_device_name(input_event)
	var matching_enums := INPUT_HELPER_DEVICE_NAME_ENUMS_MAP[device_name]
	for matching_enum in matching_enums:
		if matching_enum in sub_action_groups_input_devices:
			return matching_enum
	return -1

func _get_available_event_device_group(input_event : InputEvent, input_events: Array[InputEvent]) -> int:
	var sub_action_groups_input_devices = action_group_input_devices.duplicate()
	var device_name = InputEventHelper.get_input_device_name(input_event)
	var matching_enums := INPUT_HELPER_DEVICE_NAME_ENUMS_MAP[device_name]
	for comparing_input_event in input_events:
		if comparing_input_event == input_event: break
		var comparing_enum = _get_event_matching_enum(comparing_input_event, sub_action_groups_input_devices)
		if comparing_enum > -1:
			sub_action_groups_input_devices.erase(comparing_enum)
	var matching_enum : int = _get_event_matching_enum(input_event, sub_action_groups_input_devices)
	return action_group_input_devices.find(matching_enum)

func _assign_editing_input_event(input_event: InputEvent) -> void:
	var input_events := InputMap.action_get_events(editing_action_name)
	var action_group := _get_available_event_device_group(input_event, input_events)
	_assign_input_event_to_action_group(input_event, editing_action_name, action_group, editing_input_key)

func _replace_action(action_name : String, readable_input_name : String = "", action_group: int = -1) -> void:
	var readable_action_name := tr(_get_action_readable_name(action_name))
	var device_names := []
	if action_group >= 0:
		var input_devices_enum := action_group_input_devices[action_group]
		device_names = ENUM_INPUT_HELPER_DEVICE_NAMES_MAP[input_devices_enum]
	button_clicked.emit(readable_action_name, readable_input_name, device_names)

func _refresh_ui_list_button_content() -> void:
	var action_names : Array[StringName] = _get_all_action_names(show_built_in_actions)
	for action_name in action_names:
		var input_events := InputMap.action_get_events(action_name)
		if input_events.size() < 1:
			continue
		for group_iter in range(action_groups):
			_clear_button(action_name, group_iter)
		for input_event in input_events:
			var action_group = _get_available_event_device_group(input_event, input_events)
			if action_group == -1: continue
			_update_assigned_inputs_and_button(action_name, action_group, input_event)

func _get_input_event_action_group(input_event: InputEvent, input_events: Array[InputEvent]) -> int:
	return _get_available_event_device_group(input_event, input_events)
