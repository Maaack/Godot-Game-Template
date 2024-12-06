class_name GlobalStateData
extends Resource

@export var first_version_opened : String
@export var last_version_opened : String
@export var last_unix_time_opened : int
@export var states : Dictionary

func get_state(key_name : String, state_type_path : String):
	if key_name in states:
		return states[key_name]
	elif state_type_path:
		var new_state_script = load(state_type_path)
		var new_state : Resource
		if new_state_script is GDScript:
			new_state = new_state_script.new()
			states[key_name] = new_state
		return new_state
	else:
		return null
