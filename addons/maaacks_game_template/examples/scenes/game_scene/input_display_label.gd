extends Label

@onready var action_names = AppSettings.get_action_names()

func _get_inputs_as_string():
	var all_inputs : String = ""
	var is_first : bool = true
	for action_name in action_names:
			if Input.is_action_pressed(action_name):
				if is_first:
					is_first = false
					all_inputs += action_name
				else:
					all_inputs += " + " + action_name
	return all_inputs

func _process(_delta):
	if Input.is_anything_pressed():
		text = _get_inputs_as_string()
	else:
		text = ""
