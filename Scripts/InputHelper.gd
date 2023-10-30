extends Node
class_name InputEventHelper

const JOY_BUTTON_NAMES : Dictionary = {
	JOY_BUTTON_A: "Button A",
	JOY_BUTTON_B: "Button B",
	JOY_BUTTON_X: "Button X",
	JOY_BUTTON_Y: "Button Y",
	JOY_BUTTON_LEFT_SHOULDER: "Button Left Shoulder",
	JOY_BUTTON_RIGHT_SHOULDER: "Button Right Shoulder",
	JOY_BUTTON_LEFT_STICK: "Button Left Stick",
	JOY_BUTTON_RIGHT_STICK: "Button Right Stick",
}

const JOY_AXIS_NAMES : Dictionary = {
	JOY_AXIS_TRIGGER_LEFT: "Button Left Trigger",
	JOY_AXIS_TRIGGER_RIGHT: "Button Right Trigger",
}

static func get_text(event : InputEvent) -> String:
	if event is InputEventJoypadButton:
		if event.button_index in JOY_BUTTON_NAMES:
			return JOY_BUTTON_NAMES[event.button_index] 
	elif event is InputEventJoypadMotion:
		var full_string := ""
		var direction_string := ""
		var is_right_or_down : bool = event.axis_value > 0.0
		if event.axis in JOY_AXIS_NAMES:
			return JOY_AXIS_NAMES[event.axis]
		match(event.axis):
			JOY_AXIS_LEFT_X:
				full_string = "Left Joystick "
				direction_string = "Right" if is_right_or_down else "Left"
			JOY_AXIS_LEFT_Y:
				full_string = "Left Joystick "
				direction_string = "Down" if is_right_or_down else "Up"
			JOY_AXIS_RIGHT_X:
				full_string = "Right Joystick "
				direction_string = "Right" if is_right_or_down else "Left"
			JOY_AXIS_RIGHT_Y:
				full_string = "Right Joystick "
				direction_string = "Down" if is_right_or_down else "Up"
		full_string += direction_string
		return full_string
	elif event is InputEventKey:
		return OS.get_keycode_string(event.get_physical_keycode_with_modifiers())
	return event.as_text()
