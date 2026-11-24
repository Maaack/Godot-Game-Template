@tool
class_name InputActionsTable
extends Container
## Scene to list the input actions out as buttons in a grid format.

const EMPTY_INPUT_ACTION_STRING = " "

signal already_assigned(action_name : String, input_name : String)
signal minimum_reached(action_name : String)
signal button_clicked(action_name : String, readable_input_name : String, accepted_input_devices: Array)

const BUTTON_NAME_GROUP_STRING : String = "%s:%d"

## If true, lists action names on the vertical axis.
@export var vertical : bool = true :
	set(value):
		vertical = value
		if is_inside_tree():
			%ParentBoxContainer.vertical = vertical
## The number of inputs to make editable per action name.
@export_range(1, 5) var action_groups : int = 2
## The header to each input action group.
@export var action_group_names : Array[String]
## If true, capitalizes action names in order to make them readable.
@export var capitalize_action_names : bool = true :
	set(value):
		capitalize_action_names = value
		_refresh_readable_action_names()
## If true, show action names that are not explicitely listed in an input action name map.
@export var show_all_actions : bool = true
## Maps the names of input actions to readable names for users.
@export var action_name_map : Dictionary[StringName, String] :
	set(value):
		var _value_changed = action_name_map != value
		action_name_map = value
		if _value_changed:
			_refresh_readable_action_names()
## Optional minimum size to add to all edit buttons.
@export var button_minimum_size : Vector2
## If true, buttons are disabled after the next available action group.
@export var auto_disable_buttons : bool = true
@export_group("Icons")
## Optional link to an input icon mapper to replace the text with icons.
@export var input_icon_mapper : InputIconMapper
## If true, expand the icons to fill the buttons.
@export var expand_icon : bool = false
@export_group("Built-in Actions")
## Shows Godot's built-in actions (action names starting with "ui_") in the tree.
@export var show_built_in_actions : bool = false
## Prevents assigning inputs that are already assigned to Godot's built-in actions (action names starting with "ui_"). Not recommended.
@export var catch_built_in_duplicate_inputs : bool = false
## Maps the names of built-in input actions to readable names for users.
@export var built_in_action_name_map := InputEventHelper.BUILT_IN_ACTION_NAME_MAP

var action_button_map : Dictionary[String, Button] = {}
var button_readable_input_map : Dictionary[Button, String] = {}
var button_input_event_map : Dictionary[Button, InputEvent] = {}
var assigned_input_events : Dictionary[String, String] = {}
var editing_action_name : String = ""
var editing_action_group : int = 0
var editing_input_key : int = 0

func _refresh_readable_action_names():
	for action_name in action_name_map:
		if not action_name_map[action_name].is_empty(): continue
		var readable_action_name : String
		if capitalize_action_names:
			readable_action_name = action_name.capitalize()
		else:
			readable_action_name = action_name.replace("_", " ")
		action_name_map[action_name] = readable_action_name

func _clear_list() -> void:
	for child in %ParentBoxContainer.get_children():
		if child == %ActionBoxContainer:
			continue
		child.queue_free()

func _replace_action(action_name : String, readable_input_name : String = "", _action_group: int = -1) -> void:
	var readable_action_name = tr(_get_action_readable_name(action_name))
	button_clicked.emit(readable_action_name, readable_input_name, [])

func _on_button_pressed(action_name : String, action_group : int) -> void:
	var button = _get_button_by_action(action_name, action_group)
	editing_action_name = action_name
	editing_action_group = action_group
	editing_input_key = -1 
	if button in button_input_event_map:
		var old_input_event := button_input_event_map[button]
		var action_events := InputMap.action_get_events(action_name)
		editing_input_key = action_events.find(old_input_event)
	var readable_input_name : String
	if button and button in button_readable_input_map:
		readable_input_name = button_readable_input_map[button]
	_replace_action(action_name, readable_input_name, action_group)

func _new_action_box() -> Node:
	var new_action_box : Node = %ActionBoxContainer.duplicate()
	new_action_box.visible = true
	new_action_box.vertical = !(vertical)
	return new_action_box

func _add_header() -> void:
	if action_group_names.is_empty(): return
	var new_action_box := _new_action_box()
	for group_iter in range(action_groups):
		var group_name := ""
		if group_iter < action_group_names.size():
			group_name = action_group_names[group_iter]
		var new_label := Label.new()
		if button_minimum_size.x > 0:
			new_label.custom_minimum_size.x = button_minimum_size.x
			new_label.size_flags_horizontal = SIZE_SHRINK_CENTER
		else:
			new_label.size_flags_horizontal = SIZE_EXPAND_FILL
		if button_minimum_size.y > 0:
			new_label.custom_minimum_size.y = button_minimum_size.y
			new_label.size_flags_vertical = SIZE_SHRINK_CENTER
		else:
			new_label.size_flags_vertical = SIZE_EXPAND_FILL
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_label.text = group_name
		new_action_box.add_child(new_label)
	%ParentBoxContainer.add_child(new_action_box)

func _add_to_action_button_map(action_name : String, action_group : int, button_node : BaseButton) -> void:
	var key_string : String = BUTTON_NAME_GROUP_STRING % [action_name, action_group]
	action_button_map[key_string] = button_node

func _get_button_by_action(action_name : String, action_group : int) -> Button:
	var key_string : String = BUTTON_NAME_GROUP_STRING % [action_name, action_group]
	if key_string in action_button_map:
		return action_button_map[key_string]
	return null

func _update_next_button_disabled_state(action_name : String, action_group : int, disabled: bool = false) -> void:
	if not auto_disable_buttons: return
	var button = _get_button_by_action(action_name, action_group + 1)
	if button:
		button.disabled = disabled

func _update_assigned_inputs_and_button(action_name : String, action_group : int, input_event : InputEvent) -> void:
	var new_readable_input_name = InputEventHelper.get_text(input_event)
	var button = _get_button_by_action(action_name, action_group)
	if not button: return
	var icon : Texture
	if input_icon_mapper:
		icon = input_icon_mapper.get_icon(input_event)
	if icon:
		button.icon = icon
	else:
		button.icon = null
	if button.icon == null:
		button.text = new_readable_input_name
	else:
		button.text = ""
	var old_readable_input_name : String
	if button in button_readable_input_map:
		old_readable_input_name = button_readable_input_map[button]
		assigned_input_events.erase(old_readable_input_name)
	button_readable_input_map[button] = new_readable_input_name
	button_input_event_map[button] = input_event
	assigned_input_events[new_readable_input_name] = action_name

func _clear_button(action_name : String, action_group : int) -> void:
	var button = _get_button_by_action(action_name, action_group)
	if not button: return
	button.icon = null
	button.text = EMPTY_INPUT_ACTION_STRING
	var old_readable_input_name : String
	if button in button_readable_input_map:
		old_readable_input_name = button_readable_input_map[button]
		assigned_input_events.erase(old_readable_input_name)
	button_readable_input_map[button] = EMPTY_INPUT_ACTION_STRING
	button_input_event_map[button] = null

func _add_new_button(container: Control) -> Button:
	var new_button := Button.new()
	if button_minimum_size.x > 0:
		new_button.custom_minimum_size.x = button_minimum_size.x
		new_button.size_flags_horizontal = SIZE_SHRINK_CENTER
	else:
		new_button.size_flags_horizontal = SIZE_EXPAND_FILL
	if button_minimum_size.y > 0:
		new_button.custom_minimum_size.y = button_minimum_size.y
		new_button.size_flags_vertical = SIZE_SHRINK_CENTER
	else:
		new_button.size_flags_vertical = SIZE_EXPAND_FILL
	new_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	new_button.expand_icon = expand_icon
	container.add_child(new_button)
	return new_button

func _connect_button_signals(button : Button, action_name : String, group_iter : int) -> void:
	button.pressed.connect(_on_button_pressed.bind(action_name, group_iter))
	_add_to_action_button_map(action_name, group_iter, button)

func _get_input_event_action_group(input_event: InputEvent, input_events: Array[InputEvent]) -> int:
	return input_events.find(input_event)

func _add_action_options(action_name : String, readable_action_name : String, input_events : Array[InputEvent]) -> void:
	var new_action_box = %ActionBoxContainer.duplicate()
	new_action_box.visible = true
	new_action_box.vertical = !(vertical)
	new_action_box.get_child(0).text = readable_action_name
	for group_iter in range(action_groups):
		var button : Button = _add_new_button(new_action_box)
		button.disabled = (group_iter > input_events.size()) and auto_disable_buttons
		_connect_button_signals(button, action_name, group_iter)
	for input_event in input_events:
		var action_group = _get_input_event_action_group(input_event, input_events)
		if action_group == -1: continue
		_update_assigned_inputs_and_button(action_name, action_group, input_event)
	%ParentBoxContainer.add_child(new_action_box)

func _get_all_action_names(include_built_in : bool = false) -> Array[StringName]:
	var action_names : Array[StringName] = action_name_map.keys()
	if include_built_in:
		for action_name in built_in_action_name_map:
			action_names.append(action_name)
	if show_all_actions:
		var all_actions := AppSettings.get_action_names(include_built_in)
		for action_name in all_actions:
			if not action_name in action_names:
				action_names.append(action_name)
	return action_names

func _get_action_readable_name(action_name : StringName) -> String:
	var readable_name : String
	if action_name in action_name_map:
		readable_name = action_name_map[action_name]
	elif action_name in built_in_action_name_map:
		readable_name = built_in_action_name_map[action_name]
	else:
		readable_name = action_name
		if capitalize_action_names:
			readable_name = readable_name.capitalize()
		action_name_map[action_name] = readable_name
	return readable_name

func _build_ui_list() -> void:
	_clear_list()
	_add_header()
	var action_names : Array[StringName] = _get_all_action_names(show_built_in_actions)
	for action_name in action_names:
		var action_events := InputMap.action_get_events(action_name)
		if action_events.size() < 1:
			continue
		var readable_name : String = _get_action_readable_name(action_name)
		_add_action_options(action_name, readable_name, action_events)

func _add_assigned_input_event(input_event : InputEvent, action_name : String) -> void:
	assigned_input_events[InputEventHelper.get_text(input_event)] = action_name

func _assign_input_event_to_action_group(input_event : InputEvent, action_name : String, action_group : int, input_key: int) -> void:
	_add_assigned_input_event(input_event, action_name)
	var action_events := InputMap.action_get_events(action_name)
	action_events.resize(action_events.size() + 1)
	if input_key < 0:
		input_key = action_events.size() - 1
	action_events[input_key] = input_event
	InputMap.action_erase_events(action_name)
	var final_action_events : Array[InputEvent]
	for input_action_event in action_events:
		if input_action_event == null: continue
		final_action_events.append(input_action_event)
		InputMap.action_add_event(action_name, input_action_event)
	AppSettings.set_config_input_events(action_name, final_action_events)
	_update_assigned_inputs_and_button(action_name, action_group, input_event)
	_update_next_button_disabled_state(action_name, action_group)

func _assign_editing_input_event(input_event: InputEvent) -> void:
	_assign_input_event_to_action_group(input_event, editing_action_name, editing_action_group, editing_input_key)

func _build_assigned_input_events() -> void:
	assigned_input_events.clear()
	var action_names := _get_all_action_names(show_built_in_actions and catch_built_in_duplicate_inputs)
	for action_name in action_names:
		var input_events = InputMap.action_get_events(action_name)
		for input_event in input_events:
			_add_assigned_input_event(input_event, action_name)

func _get_action_for_input_event(input_event : InputEvent) -> String:
	if InputEventHelper.get_text(input_event) in assigned_input_events:
		return assigned_input_events[InputEventHelper.get_text(input_event)] 
	return ""

func add_action_event(input_readable_text : String, input_event : InputEvent) -> void:
	if input_event != null:
		var assigned_action := _get_action_for_input_event(input_event)
		if not assigned_action.is_empty():
			var readable_action_name = tr(_get_action_readable_name(assigned_action))
			already_assigned.emit(readable_action_name, input_readable_text)
		else:
			_assign_editing_input_event(input_event)
	editing_action_name = ""

func _refresh_ui_list_button_content() -> void:
	var action_names : Array[StringName] = _get_all_action_names(show_built_in_actions)
	for action_name in action_names:
		var input_events := InputMap.action_get_events(action_name)
		if input_events.size() < 1:
			continue
		var group_iter : int = 0
		for input_event in input_events:
			_update_assigned_inputs_and_button(action_name, group_iter, input_event)
			_update_next_button_disabled_state(action_name, group_iter)
			group_iter += 1
		while group_iter < action_groups:
			_clear_button(action_name, group_iter)
			_update_next_button_disabled_state(action_name, group_iter, true)
			group_iter += 1

func _set_action_box_container_size() -> void:
	if button_minimum_size.x > 0:
		%ActionBoxContainer.size_flags_horizontal = SIZE_SHRINK_CENTER
	else:
		%ActionBoxContainer.size_flags_horizontal = SIZE_EXPAND_FILL
	if button_minimum_size.y > 0:
		%ActionBoxContainer.size_flags_vertical = SIZE_SHRINK_CENTER
	else:
		%ActionBoxContainer.size_flags_vertical = SIZE_EXPAND_FILL

func reset() -> void:
	_build_assigned_input_events()
	_refresh_ui_list_button_content()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	vertical = vertical
	_set_action_box_container_size()
	_build_assigned_input_events()
	_build_ui_list.call_deferred()
	if input_icon_mapper:
		input_icon_mapper.joypad_device_changed.connect(_refresh_ui_list_button_content)
