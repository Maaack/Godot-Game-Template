@tool
class_name InputIconMapper
extends FileLister


const COMMON_REPLACE_STRINGS: Dictionary[String, String] = {
	"L 1": "Left Shoulder",
	"R 1": "Right Shoulder",
	"L 2": "Left Trigger",
	"R 2": "Right Trigger",
	"Lt": "Left Trigger",
	"Rt": "Right Trigger",
	"Lb": "Left Shoulder",
	"Rb": "Right Shoulder",
}
## Will use the button colored versions when available
@export var prioritized_strings : Array[String]
@export var filtered_strings : Array[String]
@export var replace_strings : Dictionary[String, String]
@export var add_stick_directions : bool = false
@export_tool_button("Match Icons to Inputs") var _match_icons_to_inputs_action = _match_icons_to_inputs
@export var matching_icons : Dictionary[String, Texture]
@export_group("Debug")
@export var all_icons : Dictionary[String, Texture]

func _is_end_of_word(full_string : String, what : String):
	var string_end_position = full_string.find(what) + what.length()
	var end_of_word : bool
	if string_end_position + 1 < full_string.length():
		var next_character = full_string.substr(string_end_position, 1)
		end_of_word = next_character == " "
	return full_string.ends_with(what) or end_of_word

func _get_standard_joy_name(joy_name : String) -> String:
	var all_replace_strings = replace_strings.duplicate()
	all_replace_strings.merge(COMMON_REPLACE_STRINGS)
	for what in all_replace_strings:
		if joy_name.contains(what) and _is_end_of_word(joy_name, what):
			joy_name = joy_name.replace(what, all_replace_strings[what])
	var combined_joystick_name : Array[String] = []
	for part in joy_name.split(" "):
		if part.to_lower() in filtered_strings:
			continue
		if not part.is_empty():
			combined_joystick_name.append(part)
	joy_name = " ".join(combined_joystick_name)
	joy_name = joy_name.strip_edges()
	return joy_name

func _match_icon_to_file(file : String):
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
	var priority_levels : Dictionary[String, int]
	var priortized_files : Array[String]
	for prioritized_string in prioritized_strings:
		for file in files:
			if file.containsn(prioritized_string):
				if file in priority_levels:
					priority_levels[file] += 1
				else:
					priority_levels[file] = 1
	var priority_file_map : Dictionary[int, Array]
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

func _match_icons_to_inputs():
	matching_icons.clear()
	for prioritized_file in _prioritized_files():
		_match_icon_to_file(prioritized_file)
	for file in files:
		_match_icon_to_file(file)

func get_icon(input_string : String, device : String = "") -> Texture:
	if not device.is_empty():
		input_string = "%s %s" % [device, input_string]
	if input_string in matching_icons:
		return matching_icons[input_string]
	return null
