@tool
class_name InputActionsList
extends Container

const EMPTY_INPUT_ACTION_STRING = " "

signal already_assigned(action_name : String, input_name : String)
signal minimum_reached(action_name : String)
signal button_clicked(action_name : String, readable_input_name : String)

const BUTTON_NAME_GROUP_STRING : String = "%s:%d"

@export var vertical : bool = true :
	set(value):
		vertical = value
		if is_inside_tree():
			%ParentBoxContainer.vertical = vertical

@export_range(1, 5) var action_groups : int = 2
@export var action_group_names : Array[String]
@export var input_action_names : Array[StringName] :
	set(value):
		var _value_changed = input_action_names != value
		input_action_names = value
		if _value_changed:
			var _new_readable_action_names : Array[String]
			for action in input_action_names:
				_new_readable_action_names.append(action.capitalize())
			readable_action_names = _new_readable_action_names

@export var readable_action_names : Array[String] :
	set(value):
		var _value_changed = readable_action_names != value
		readable_action_names = value
		if _value_changed:
			var _new_action_name_map : Dictionary
			for iter in range(input_action_names.size()):
				var _input_name : StringName = input_action_names[iter]
				var _readable_name : String = readable_action_names[iter]
				_new_action_name_map[_input_name] = _readable_name
			action_name_map = _new_action_name_map

## Show action names that are not explicitely listed in an action name map.
@export var show_all_actions : bool = true
@export var button_minimum_size : Vector2
@export_group("Icons")
@export var input_icon_mapper : InputIconMapper
@export var expand_icon : bool = false
@export_group("Built-in Actions")
## Shows Godot's built-in actions (action names starting with "ui_") in the tree.
@export var show_built_in_actions : bool = false
## Prevents assigning inputs that are already assigned to Godot's built-in actions (action names starting with "ui_"). Not recommended.
@export var catch_built_in_duplicate_inputs : bool = false
## Maps the names of built-in input actions to readable names for users.
@export var built_in_action_name_map := InputEventHelper.BUILT_IN_ACTION_NAME_MAP
@export_group("Debug")
## Maps the names of input actions to readable names for users.
@export var action_name_map : Dictionary

var action_button_map : Dictionary = {}
var button_readable_input_map : Dictionary = {}
var assigned_input_events : Dictionary = {}
var editing_action_name : String = ""
var editing_action_group : int = 0
var last_input_readable_name

func _clear_list() -> void:
	for child in %ParentBoxContainer.get_children():
		if child == %ActionBoxContainer:
			continue
		child.queue_free()

func _replace_action(action_name : String, readable_input_name : String = "") -> void:
	var readable_action_name = tr(_get_action_readable_name(action_name))
	button_clicked.emit(readable_action_name, readable_input_name)

func _on_button_pressed(action_name : String, action_group : int) -> void:
	editing_action_name = action_name
	editing_action_group = action_group
	_replace_action(action_name)

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

func _update_next_button_disabled_state(action_name : String, action_group : int) -> void:
	var button = _get_button_by_action(action_name, action_group)
	if button:
		button.disabled = false

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

func _add_new_button(content : Variant, container: Control, disabled : bool = false) -> Button:
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
	if content is Texture:
		new_button.icon = content
	elif content is String:
		new_button.text = content
	new_button.disabled = disabled
	container.add_child(new_button)
	return new_button

func _connect_button_and_add_to_maps(button : Button, input_name : String, action_name : String, group_iter : int) -> void:
	button.pressed.connect(_on_button_pressed.bind(action_name, group_iter))
	button_readable_input_map[button] = input_name
	_add_to_action_button_map(action_name, group_iter, button)

func _add_action_options(action_name : String, readable_action_name : String, input_events : Array[InputEvent]) -> void:
	var new_action_box = %ActionBoxContainer.duplicate()
	new_action_box.visible = true
	new_action_box.vertical = !(vertical)
	new_action_box.get_child(0).text = readable_action_name
	for group_iter in range(action_groups):
		var input_event : InputEvent
		if group_iter < input_events.size():
			input_event = input_events[group_iter]
		var text = InputEventHelper.get_text(input_event)
		var is_disabled = group_iter > input_events.size()
		if text.is_empty(): text = EMPTY_INPUT_ACTION_STRING
		var icon : Texture
		if input_icon_mapper:
			icon = input_icon_mapper.get_icon(input_event)
		var content = icon if icon else text
		var button : Button = _add_new_button(content, new_action_box, is_disabled)
		_connect_button_and_add_to_maps(button, text, action_name, group_iter)
	%ParentBoxContainer.add_child(new_action_box)

func _get_all_action_names(include_built_in : bool = false) -> Array[StringName]:
	var action_names : Array[StringName] = input_action_names.duplicate()
	var full_action_name_map = action_name_map.duplicate()
	if include_built_in:
		for action_name in built_in_action_name_map:
			if action_name is String:
				action_name = StringName(action_name)
			if action_name is StringName:
				action_names.append(action_name)
	if show_all_actions:
		var all_actions := AppSettings.get_action_names(include_built_in)
		for action_name in all_actions:
			if not action_name in action_names:
				action_names.append(action_name)
	return action_names

func _get_action_readable_name(input_name : StringName) -> String:
	var readable_name : String
	if input_name in action_name_map:
		readable_name = action_name_map[input_name]
	elif input_name in built_in_action_name_map:
		readable_name = built_in_action_name_map[input_name]
	else:
		readable_name = input_name.capitalize()
		action_name_map[input_name] = readable_name
	return readable_name

func _build_ui_list() -> void:
	_clear_list()
	_add_header()
	var action_names : Array[StringName] = _get_all_action_names(show_built_in_actions)
	for action_name in action_names:
		var input_events = InputMap.action_get_events(action_name)
		if input_events.size() < 1:
			continue
		var readable_name : String = _get_action_readable_name(action_name)
		_add_action_options(action_name, readable_name, input_events)

func _assign_input_event(input_event : InputEvent, action_name : String) -> void:
	assigned_input_events[InputEventHelper.get_text(input_event)] = action_name
		
func _assign_input_event_to_action_group(input_event : InputEvent, action_name : String, action_group : int) -> void:
	_assign_input_event(input_event, action_name)
	var action_events := InputMap.action_get_events(action_name)
	action_events.resize(action_events.size() + 1)
	action_events[action_group] = input_event
	InputMap.action_erase_events(action_name)
	var final_action_events : Array[InputEvent]
	for input_action_event in action_events:
		if input_action_event == null: continue
		final_action_events.append(input_action_event)
		InputMap.action_add_event(action_name, input_action_event)
	AppSettings.set_config_input_events(action_name, final_action_events)
	action_group = min(action_group, final_action_events.size() - 1)
	_update_assigned_inputs_and_button(action_name, action_group, input_event)
	_update_next_button_disabled_state(action_name, action_group)

func _build_assigned_input_events() -> void:
	assigned_input_events.clear()
	var action_names := _get_all_action_names(show_built_in_actions and catch_built_in_duplicate_inputs)
	for action_name in action_names:
		var input_events = InputMap.action_get_events(action_name)
		for input_event in input_events:
			_assign_input_event(input_event, action_name)

func _get_action_for_input_event(input_event : InputEvent) -> String:
	if InputEventHelper.get_text(input_event) in assigned_input_events:
		return assigned_input_events[InputEventHelper.get_text(input_event)] 
	return ""

func add_action_event(last_input_text : String, last_input_event : InputEvent) -> void:
	last_input_readable_name = last_input_text
	if last_input_event != null:
		var assigned_action := _get_action_for_input_event(last_input_event)
		if not assigned_action.is_empty():
			var readable_action_name = tr(_get_action_readable_name(assigned_action))
			already_assigned.emit(readable_action_name, last_input_readable_name)
		else:
			_assign_input_event_to_action_group(last_input_event, editing_action_name, editing_action_group)
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
			group_iter += 1
		while group_iter < action_groups:
			_clear_button(action_name, group_iter)
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
	AppSettings.reset_to_default_inputs()
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
