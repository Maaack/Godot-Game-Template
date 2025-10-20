class_name GlobalStateData
extends Resource

@export var first_version_opened : String
@export var last_version_opened : String
@export var last_unix_time_opened : int
@export var states : Dictionary

func get_or_create_state(key_name : String, state_type_path : String) -> Resource:
	var new_state : Resource
	var new_state_script = load(state_type_path)
	if new_state_script is GDScript:
		new_state = new_state_script.new()
	if key_name in states:
		var saved_state : Resource = states[key_name]
		var saved_script = saved_state.get_script()
		var new_script = new_state.get_script()
		if saved_script and new_script and saved_script == new_script:
			return saved_state
	states[key_name] = new_state
	return new_state

func has_state(key_name : String) -> bool:
	return key_name in states
