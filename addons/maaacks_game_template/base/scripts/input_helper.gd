class_name InputEventHelper
extends Node
## Helper class for organizing constants related to [InputEvent].

const DEVICE_KEYBOARD = "Keyboard"
const DEVICE_MOUSE = "Mouse"
const DEVICE_XBOX_CONTROLLER = "Xbox"
const DEVICE_SWITCH_CONTROLLER = "Switch"
const DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER = "Switch Left Joycon"
const DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER = "Switch Right Joycon"
const DEVICE_SWITCH_JOYCON_COMBINED_CONTROLLER = "Switch Combined Joycons"
const DEVICE_PLAYSTATION_CONTROLLER = "Playstation"
const DEVICE_STEAMDECK_CONTROLLER = "Steamdeck"
const DEVICE_GENERIC = "Generic"

const JOYSTICK_LEFT_NAME = "Left Stick"
const JOYSTICK_RIGHT_NAME = "Right Stick"
const D_PAD_NAME = "D-pad"

const SDL_DEVICE_NAMES: Dictionary = {
	DEVICE_XBOX_CONTROLLER: ["XInput", "XBox"],
	DEVICE_PLAYSTATION_CONTROLLER: ["Sony", "PS5", "PS4", "Nacon"],
	DEVICE_STEAMDECK_CONTROLLER: ["Steam"],
	DEVICE_SWITCH_CONTROLLER: ["Switch"],
	DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER: ["Joy-Con (L)", "Left Joy-Con"],
	DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER: ["Joy-Con (R)", "Right Joy-Con"],
	DEVICE_SWITCH_JOYCON_COMBINED_CONTROLLER: ["Joy-Con (L/R)", "Combined Joy-Cons"],
}

const JOY_BUTTON_NAMES : Dictionary = {
	JOY_BUTTON_A: "Button A",
	JOY_BUTTON_B: "Button B",
	JOY_BUTTON_X: "Button X",
	JOY_BUTTON_Y: "Button Y",
	JOY_BUTTON_LEFT_SHOULDER: "Left Shoulder",
	JOY_BUTTON_RIGHT_SHOULDER: "Right Shoulder",
	JOY_BUTTON_LEFT_STICK: "Left Trigger",
	JOY_BUTTON_RIGHT_STICK: "Right Trigger",
	JOY_BUTTON_START : "Start",
	JOY_BUTTON_GUIDE : "Guide",
	JOY_BUTTON_BACK : "Back",
	JOY_BUTTON_DPAD_UP : D_PAD_NAME + " Up",
	JOY_BUTTON_DPAD_DOWN : D_PAD_NAME + " Down",
	JOY_BUTTON_DPAD_LEFT : D_PAD_NAME + " Left",
	JOY_BUTTON_DPAD_RIGHT : D_PAD_NAME + " Right",
}

const JOY_AXIS_NAMES : Dictionary = {
	JOY_AXIS_TRIGGER_LEFT: "Left Trigger Gamepad Button",
	JOY_AXIS_TRIGGER_RIGHT: "Right Trigger Gamepad Button",
}

const BUILT_IN_ACTION_NAME_MAP : Dictionary = {
	"ui_accept" : "Accept",
	"ui_select" : "Select",
	"ui_cancel" : "Cancel",
	"ui_focus_next" : "Focus Next",
	"ui_focus_prev" : "Focus Prev",
	"ui_left" : "Left (UI)",
	"ui_right" : "Right (UI)",
	"ui_up" : "Up (UI)",
	"ui_down" : "Down (UI)",
	"ui_page_up" : "Page Up",
	"ui_page_down" : "Page Down",
	"ui_home" : "Home",
	"ui_end" : "End",
	"ui_cut" : "Cut",
	"ui_copy" : "Copy",
	"ui_paste" : "Paste",
	"ui_undo" : "Undo",
	"ui_redo" : "Redo",
}


static func has_joypad() -> bool:
	return Input.get_connected_joypads().size() > 0

static func get_generic_device_name(device_name: String) -> String:
	for device_key in SDL_DEVICE_NAMES:
		for keyword in SDL_DEVICE_NAMES[device_key]:
			if device_name.containsn(keyword):
				return device_key
	return DEVICE_GENERIC

static func get_non_generic_device_name(device_name: String) -> String:
	var result_name = get_generic_device_name(device_name)
	if result_name == DEVICE_GENERIC:
		return DEVICE_XBOX_CONTROLLER
	return DEVICE_GENERIC

static func _display_server_supports_keycode_from_physical():
	return OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linux")

static func get_text(event : InputEvent) -> String:
	if event == null:
		return ""
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
		if _display_server_supports_keycode_from_physical():
			keycode = DisplayServer.keyboard_get_keycode_from_physical(keycode)
		return OS.get_keycode_string(keycode)
	return event.as_text()
