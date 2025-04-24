@tool
class_name InputIconMapper
extends FileLister

signal joypad_device_changed

const COMMON_REPLACE_STRINGS: Dictionary = {
	"L 1": "Left Shoulder",
	"R 1": "Right Shoulder",
	"L 2": "Left Trigger",
	"R 2": "Right Trigger",
	"Lt": "Left Trigger",
	"Rt": "Right Trigger",
	"Lb": "Left Shoulder",
	"Rb": "Right Shoulder",
} # Dictionary[String, String]
## Gives priority to icons with occurrences of the provided strings.
@export var prioritized_strings : Array[String]
## Replaces the first occurence in icon names of the key with the value.
@export var replace_strings : Dictionary # Dictionary[String, String]
## Filters the icon names of the provided strings.
@export var filtered_strings : Array[String]
## Adds entries for "Up", "Down", "Left", "Right" to icon names ending with "Stick".
@export var add_stick_directions : bool = false
@export var intial_joypad_device : String = InputEventHelper.DEVICE_GENERIC
## Attempt to match the icon names to the input names based on the string rules.
@export var _match_icons_to_inputs_action : bool = false :
	set(value):
		if value and Engine.is_editor_hint():
			_match_icons_to_inputs()
# For Godot 4.4
# @export_tool_button("Match Icons to Inputs") var _match_icons_to_inputs_action = _match_icons_to_inputs
@export var matching_icons : Dictionary # Dictionary[String, Texture]
@export_group("Debug")
@export var all_icons : Dictionary # Dictionary[String, Texture]

@onready var last_joypad_device = intial_joypad_device

func _is_end_of_word(full_string : String, what : String) -> bool:
	var string_end_position = full_string.find(what) + what.length()
	var end_of_word : bool
	if string_end_position + 1 < full_string.length():
		var next_character = full_string.substr(string_end_position, 1)
		end_of_word = next_character == " "
	return full_string.ends_with(what) or end_of_word

func _get_standard_joy_name(joy_name : String) -> String:
	var all_replace_strings := replace_strings.duplicate()
	all_replace_strings.merge(COMMON_REPLACE_STRINGS)
	for what in all_replace_strings:
		if joy_name.contains(what) and _is_end_of_word(joy_name, what):
			var position = joy_name.find(what)
			joy_name = joy_name.erase(position, what.length())
			joy_name = joy_name.insert(position, all_replace_strings[what])
	var combined_joystick_name : Array[String] = []
	for part in joy_name.split(" "):
		if part.to_lower() in filtered_strings:
			continue
		if not part.is_empty():
			combined_joystick_name.append(part)
	joy_name = " ".join(combined_joystick_name)
	joy_name = joy_name.strip_edges()
	return joy_name

func _match_icon_to_file(file : String) -> void:
	var matching_string : String = file.get_file().get_basename()
	var icon : Texture = load(file)
	if not icon:
		return
	all_icons[matching_string] = icon
	matching_string = matching_string.capitalize()
	matching_string = _get_standard_joy_name(matching_string)
	matching_string = matching_string.strip_edges()
	if add_stick_directions and matching_string.ends_with("Stick"):
		matching_icons[matching_string + " Up"] = icon
		matching_icons[matching_string + " Down"] = icon
		matching_icons[matching_string + " Left"] = icon
		matching_icons[matching_string + " Right"] = icon
		return
	if matching_string in matching_icons:
		return
	matching_icons[matching_string] = icon

func _prioritized_files() -> Array[String]:
	var priority_levels : Dictionary # Dictionary[String, int]
	var priortized_files : Array[String]
	for prioritized_string in prioritized_strings:
		for file in files:
			if file.containsn(prioritized_string):
				if file in priority_levels:
					priority_levels[file] += 1
				else:
					priority_levels[file] = 1
	var priority_file_map : Dictionary # Dictionary[int, Array]
	var max_priority_level : int = 0
	for file in priority_levels:
		var priority_level = priority_levels[file]
		max_priority_level = max(priority_level, max_priority_level)
		if priority_level in priority_file_map:
			priority_file_map[priority_level].append(file)
		else:
			priority_file_map[priority_level] = [file]
	while max_priority_level > 0:
		for priority_file in priority_file_map[max_priority_level]:
			priortized_files.append(priority_file)
		max_priority_level -= 1
	return priortized_files

func _match_icons_to_inputs() -> void:
	matching_icons.clear()
	all_icons.clear()
	for prioritized_file in _prioritized_files():
		_match_icon_to_file(prioritized_file)
	for file in files:
		_match_icon_to_file(file)

func get_icon(input_event : InputEvent) -> Texture:
	var specific_text = InputEventHelper.get_device_specific_text(input_event, last_joypad_device)
	if specific_text in matching_icons:
		return matching_icons[specific_text]
	return null

func _assign_joypad_0_to_last() -> void:
	if last_joypad_device != intial_joypad_device : return
	var connected_joypads := Input.get_connected_joypads()
	if connected_joypads.is_empty(): return
	last_joypad_device = InputEventHelper.get_device_name_by_id(connected_joypads[0])

func _input(event : InputEvent) -> void:
	var device_name = InputEventHelper.get_device_name(event)
	if device_name != InputEventHelper.DEVICE_GENERIC and device_name != last_joypad_device:
		last_joypad_device = device_name
		joypad_device_changed.emit()

func _ready() -> void:
	_assign_joypad_0_to_last()
	if files.size() == 0:
		_refresh_files()
	if matching_icons.size() == 0:
		_match_icons_to_inputs()
