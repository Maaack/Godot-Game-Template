class_name InputActionsTree
extends Tree

signal already_assigned(action_name : String, input_name : String)
signal minimum_reached(action_name : String)
signal add_button_clicked(action_name : String)
signal remove_button_clicked(action_name : String, input_name : String)

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
@export_group("Icons")
@export var add_button_texture : Texture2D
@export var remove_button_texture : Texture2D
@export var input_icon_mapper : InputIconMapper
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

var tree_item_add_map : Dictionary = {}
var tree_item_remove_map : Dictionary = {}
var tree_item_action_map : Dictionary = {}
var assigned_input_events : Dictionary = {}
var editing_action_name : String = ""
var editing_item
var last_input_readable_name

func _start_tree() -> void:
	clear()
	create_item()

func _add_input_event_as_tree_item(action_name : String, input_event : InputEvent, parent_item : TreeItem) -> void:
	var input_tree_item : TreeItem = create_item(parent_item)
	var icon : Texture
	if input_icon_mapper:
		icon = input_icon_mapper.get_icon(input_event)
	if icon:
		input_tree_item.set_icon(0, icon)
	input_tree_item.set_text(0, InputEventHelper.get_text(input_event))
	if remove_button_texture != null:
		input_tree_item.add_button(0, remove_button_texture, -1, false, "Remove")
	tree_item_remove_map[input_tree_item] = input_event
	tree_item_action_map[input_tree_item] = action_name

func _add_action_as_tree_item(readable_name : String, action_name : String, input_events : Array[InputEvent]) -> void:
	var root_tree_item : TreeItem = get_root()
	var action_tree_item : TreeItem = create_item(root_tree_item)
	action_tree_item.set_text(0, readable_name)
	tree_item_add_map[action_tree_item] = action_name
	if add_button_texture != null:
		action_tree_item.add_button(0, add_button_texture, -1, false, "Add")
	for input_event in input_events:
		_add_input_event_as_tree_item(action_name, input_event, action_tree_item)

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

func _build_ui_tree() -> void:
	_start_tree()
	var action_names : Array[StringName] = _get_all_action_names(show_built_in_actions)
	for action_name in action_names:
		var input_events = InputMap.action_get_events(action_name)
		if input_events.size() < 1:
			continue
		var readable_name : String = _get_action_readable_name(action_name)
		_add_action_as_tree_item(readable_name, action_name, input_events)

func _assign_input_event(input_event : InputEvent, action_name : String) -> void:
	assigned_input_events[InputEventHelper.get_text(input_event)] = action_name
		
func _assign_input_event_to_action(input_event : InputEvent, action_name : String) -> void:
	_assign_input_event(input_event, action_name)
	InputMap.action_add_event(action_name, input_event)
	var action_events = InputMap.action_get_events(action_name)
	AppSettings.set_config_input_events(action_name, action_events)
	_add_input_event_as_tree_item(action_name, input_event, editing_item)

func _can_remove_input_event(action_name : String) -> bool:
	return InputMap.action_get_events(action_name).size() > 1

func _remove_input_event(input_event : InputEvent) -> void:
	assigned_input_events.erase(InputEventHelper.get_text(input_event))

func _remove_input_event_from_action(input_event : InputEvent, action_name : String) -> void:
	_remove_input_event(input_event)
	AppSettings.remove_action_input_event(action_name, input_event)

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

func add_action_event(last_input_text : String, last_input_event : InputEvent):
	last_input_readable_name = last_input_text
	if last_input_event != null:
		var assigned_action := _get_action_for_input_event(last_input_event)
		if not assigned_action.is_empty():
			var readable_action_name = tr(_get_action_readable_name(assigned_action))
			already_assigned.emit(readable_action_name, last_input_readable_name)
		else:
			_assign_input_event_to_action(last_input_event, editing_action_name)
	editing_action_name = ""

func remove_action_event(item : TreeItem) -> void:
	if item not in tree_item_remove_map:
		return
	var action_name = tree_item_action_map[item]
	var input_event = tree_item_remove_map[item]
	if not _can_remove_input_event(action_name):
		var readable_action_name = _get_action_readable_name(action_name)
		minimum_reached.emit(readable_action_name)
		return
	_remove_input_event_from_action(input_event, action_name)
	var parent_tree_item = item.get_parent()
	parent_tree_item.remove_child(item)

func reset() -> void:
	AppSettings.reset_to_default_inputs()
	_build_assigned_input_events()
	_build_ui_tree()

func _add_item(item : TreeItem) -> void:
	editing_item = item
	editing_action_name = tree_item_add_map[item]
	var readable_action_name = tr(_get_action_readable_name(editing_action_name))
	add_button_clicked.emit(readable_action_name)

func _remove_item(item : TreeItem) -> void:
	editing_item = item
	editing_action_name = tree_item_action_map[item]
	var readable_action_name = tr(_get_action_readable_name(editing_action_name))
	var item_text = item.get_text(0)
	remove_button_clicked.emit(readable_action_name, item_text)

func _check_item_actions(item : TreeItem) -> void:
	if item in tree_item_add_map:
		_add_item(item)
	elif item in tree_item_remove_map:
		_remove_item(item)

func _on_button_clicked(item : TreeItem, _column, _id, _mouse_button_index) -> void:
	_check_item_actions(item)

func _on_item_activated() -> void:
	var item = get_selected()
	_check_item_actions(item)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_build_assigned_input_events()
	_build_ui_tree.call_deferred()
	button_clicked.connect(_on_button_clicked)
	item_activated.connect(_on_item_activated)
	if input_icon_mapper:
		input_icon_mapper.joypad_device_changed.connect(_build_ui_tree)
