@tool
class_name InputIconMapper
extends FileLister

@export_tool_button("Match Icons to Inputs") var _match_icons_to_inputs_action = _match_icons_to_inputs

const KEYBOARD_INPUT_NAMES : Array[String] = ["keyboard", "kb", "key"]
const MOUSE_INPUT_NAMES : Array[String] = ["mouse", "mouse_button"]
const FILTERED_STRINGS : Array[String] = KEYBOARD_INPUT_NAMES + MOUSE_INPUT_NAMES

const REPLACE_PART_MAP :  Dictionary[String, String] = {
	"LB": " Left Shoulder",
	"RB": " Right Shoulder",
	"Lb": " Left Shoulder",
	"Rb": " Right Shoulder",
	"LS": " Left Trigger",
	"RS": " Right Trigger",
	"Ls": " Left Trigger",
	"Rs": " Right Trigger",
	"L": " Left Trigger",
	"R": " Right Trigger",
	"Lt": " Left Trigger",
	"Rt": " Right Trigger",
}
const REPLACE_NAMES_MAP : Dictionary[String, String] = {
	"Stick L": "Left Stick",
	"Stick R": "Right Stick",
}

@export var matching_icons : Dictionary[String, Texture] = {}
@export_group("Debug")
@export var all_icons : Dictionary[String, Texture] = {}

func _get_standard_joy_name(joystick_name : String) -> String:
	for what in REPLACE_NAMES_MAP:
		if joystick_name.contains(what):
			joystick_name = joystick_name.replace(what, REPLACE_NAMES_MAP[what])
			break
	var combined_joystick_name : String = ""
	for part in joystick_name.split(" "):
		if part in REPLACE_PART_MAP:
			combined_joystick_name += REPLACE_PART_MAP[part]
		else:
			combined_joystick_name += " %s" % part
	joystick_name = combined_joystick_name.strip_edges()
	return joystick_name

func _match_icons_to_inputs():
	matching_icons.clear()
	for file in files:
		var matching_string : String = file.get_file().get_basename()
		var icon : Texture = load(file)
		if not icon:
			continue
		all_icons[matching_string] = icon
		matching_string = matching_string.capitalize()
		matching_string = _get_standard_joy_name(matching_string)
		for filtered_string in FILTERED_STRINGS:
			matching_string = matching_string.replacen(filtered_string, "")
		matching_string = matching_string.strip_edges()
		if matching_string in matching_icons:
			continue
		matching_icons[matching_string] = icon

func get_icon(input_string : String) -> Texture:
	if input_string not in matching_icons:
		print("why not %s" % input_string)
		return null
	return matching_icons[input_string]
