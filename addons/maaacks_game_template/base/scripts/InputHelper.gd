class_name InputEventHelper
extends Node
## Helper class for organizing constants related to [InputEvent].

const JOYSTICK_LEFT_NAME = "Left Gamepad Joystick"
const JOYSTICK_RIGHT_NAME = "Right Gamepad Joystick"
const D_PAD_NAME = "Gamepad D-pad"

const JOY_BUTTON_NAMES : Dictionary = {
	JOY_BUTTON_A: "A Gamepad Button",
	JOY_BUTTON_B: "B Gamepad Button",
	JOY_BUTTON_X: "X Gamepad Button",
	JOY_BUTTON_Y: "Y Gamepad Button",
	JOY_BUTTON_LEFT_SHOULDER: "Left Shoulder Gamepad Button",
	JOY_BUTTON_RIGHT_SHOULDER: "Right Shoulder Gamepad Button",
	JOY_BUTTON_LEFT_STICK: "Left Stick Gamepad Button",
	JOY_BUTTON_RIGHT_STICK: "Right Stick Gamepad Button",
	JOY_BUTTON_START : "Start Gamepad Button",
	JOY_BUTTON_GUIDE : "Guide Gamepad Button",
	JOY_BUTTON_BACK : "Back Gamepad Button",
	JOY_BUTTON_DPAD_UP : D_PAD_NAME + " Up",
	JOY_BUTTON_DPAD_DOWN : D_PAD_NAME + " Down",
	JOY_BUTTON_DPAD_LEFT : D_PAD_NAME + " Left",
	JOY_BUTTON_DPAD_RIGHT : D_PAD_NAME + " Right",
	
}

const JOY_AXIS_NAMES : Dictionary = {
	JOY_AXIS_TRIGGER_LEFT: "Left Trigger Gamepad Button",
	JOY_AXIS_TRIGGER_RIGHT: "Right Trigger Gamepad Button",
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
				full_string = JOYSTICK_LEFT_NAME
				direction_string = "Right" if is_right_or_down else "Left"
			JOY_AXIS_LEFT_Y:
				full_string = JOYSTICK_LEFT_NAME
				direction_string = "Down" if is_right_or_down else "Up"
			JOY_AXIS_RIGHT_X:
				full_string = JOYSTICK_RIGHT_NAME
				direction_string = "Right" if is_right_or_down else "Left"
			JOY_AXIS_RIGHT_Y:
				full_string = JOYSTICK_RIGHT_NAME
				direction_string = "Down" if is_right_or_down else "Up"
		full_string += " " + direction_string
		return full_string
	elif event is InputEventKey:
		var keycode : Key = event.get_physical_keycode()
		if keycode:
			keycode = event.get_physical_keycode_with_modifiers()
		else:
			keycode = event.get_keycode_with_modifiers()
		keycode = DisplayServer.keyboard_get_keycode_from_physical(keycode)
		return OS.get_keycode_string(keycode)
	return event.as_text()
