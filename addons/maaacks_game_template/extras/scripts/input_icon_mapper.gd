@tool
class_name InputIconMapper
extends FileLister

@export_tool_button("Match Icons to Inputs") var _match_icons_to_inputs_action = _match_icons_to_inputs

const KEYBOARD_INPUT_NAMES : Array[String] = ["keyboard", "kb", "key"]
const MOUSE_INPUT_NAMES : Array[String] = ["mouse", "mouse_button"]
const PLAYSTATION_INPUT_NAMES : Array[String] = ["playstation"]
const XBOX_INPUT_NAMES : Array[String] = ["xbox"]
const FILTERED_STRINGS : Array[String] = KEYBOARD_INPUT_NAMES + MOUSE_INPUT_NAMES

@export var matching_strings : Dictionary[String, String] = {}
@export var matching_icons : Dictionary[String, Texture] = {}

func _match_icons_to_inputs():
	matching_strings.clear()
	matching_icons.clear()
	for file in files:
		var matching_string : String = file.get_file().get_basename()
		matching_string = matching_string.strip_edges()
		matching_string = matching_string.capitalize()
		for filtered_string in FILTERED_STRINGS:
			matching_string = matching_string.replacen(filtered_string, "")
		var icon : Texture = load(file)
		matching_strings[matching_string] = file
		matching_icons[matching_string] = icon
