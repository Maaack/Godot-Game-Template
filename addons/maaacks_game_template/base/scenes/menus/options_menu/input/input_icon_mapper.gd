@tool
class_name InputIconMapper
extends FileLister


const KEYBOARD_INPUT_NAMES : Array[String] = ["keyboard", "kb", "key"]
const MOUSE_INPUT_NAMES : Array[String] = ["mouse", "mouse_button"]
const FILTERED_STRINGS : Array[String] = KEYBOARD_INPUT_NAMES + MOUSE_INPUT_NAMES

const REPLACE_PART_MAP :  Dictionary[String, String] = {
	"LB": "Left Shoulder",
	"RB": "Right Shoulder",
	"Lb": "Left Shoulder",
	"Rb": "Right Shoulder",
	"LS": "Left Trigger",
	"RS": "Right Trigger",
	"Ls": "Left Trigger",
	"Rs": "Right Trigger",
	"L": "Left Trigger",
	"R": "Right Trigger",
	"Lt": "Left Trigger",
	"Rt": "Right Trigger",
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

func _get_standard_joy_name(joy_name : String) -> String:
	for what in replace_strings:
		if joy_name.contains(what):
			joy_name = joy_name.replace(what, replace_strings[what])
	var combined_joystick_name : Array[String] = []
	for part in joy_name.split(" "):
		if part.to_lower() in filtered_strings:
			continue
		if part.is_valid_int():
			continue
		if not combined_joystick_name.is_empty() and part in REPLACE_PART_MAP:
			part = REPLACE_PART_MAP[part]
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
	for filtered_string in FILTERED_STRINGS:
		matching_string = matching_string.replacen(filtered_string, "")
	matching_string = matching_string.strip_edges()
	if matching_string in matching_icons:
		return
	matching_icons[matching_string] = icon
	if add_stick_directions and matching_string.ends_with("Stick"):
		matching_icons[matching_string + " Up"] = icon
		matching_icons[matching_string + " Down"] = icon
		matching_icons[matching_string + " Left"] = icon
		matching_icons[matching_string + " Right"] = icon

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
