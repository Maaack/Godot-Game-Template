class_name GlobalStateData
extends Resource

@export var first_version_opened : String
@export var last_version_opened : String
@export var last_unix_time_opened : int
@export var states : Dictionary

func get_state(key_name : String, state_type_path : String):
	var new_state : Resource
	var new_state_script = load(state_type_path)
	if new_state_script is GDScript:
		new_state = new_state_script.new()
	if key_name in states:
		var state_value : Resource = states[key_name]
		if state_value.get_class() == new_state.get_class():
			return state_value
	states[key_name] = new_state
	return new_state
