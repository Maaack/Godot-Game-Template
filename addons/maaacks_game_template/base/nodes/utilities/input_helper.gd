class_name InputEventHelper
extends Node
## Helper class for organizing constants related to [InputEvent].

const DEVICE_KEYBOARD = "Keyboard"
const DEVICE_MOUSE = "Mouse"
const DEVICE_JOYPAD = "Joypad"
const DEVICE_SCREEN = "Screen"
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
const D_PAD_NAME = "Dpad"

const MOUSE_BUTTONS : Array = ["None", "Left", "Right", "Middle", "Scroll Up", "Scroll Down", "Wheel Left", "Wheel Right"]

const JOYPAD_BUTTON_NAME_MAP : Dictionary = {
	DEVICE_GENERIC : ["Trigger A", "Trigger B", "Trigger C", "", "", "", "", "Left Stick Press", "Right Stick Press", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right"],
	DEVICE_XBOX_CONTROLLER : ["A", "B", "X", "Y", "View", "Home", "Menu", "Left Stick Press", "Right Stick Press", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Share"],
	DEVICE_SWITCH_CONTROLLER : ["B", "A", "Y", "X", "Minus", "", "Plus", "Left Stick Press", "Right Stick Press", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Capture"],
	DEVICE_PLAYSTATION_CONTROLLER : ["Cross", "Circle", "Square", "Triangle", "Select", "PS", "Options", "Left Stick Press", "Right Stick Press", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right", "Microphone"],
	DEVICE_STEAMDECK_CONTROLLER : ["A", "B", "X", "Y", "View", "", "Options", "Left Stick Press", "Right Stick Press", "Left Shoulder", "Right Shoulder", "Up", "Down", "Left", "Right"]
} # Dictionary[String, Array]

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
	JOY_BUTTON_LEFT_STICK: "Left Stick",
	JOY_BUTTON_RIGHT_STICK: "Right Stick",
	JOY_BUTTON_START : "Button Start",
	JOY_BUTTON_GUIDE : "Button Guide",
	JOY_BUTTON_BACK : "Button Back",
	JOY_BUTTON_DPAD_UP : D_PAD_NAME + " Up",
	JOY_BUTTON_DPAD_DOWN : D_PAD_NAME + " Down",
	JOY_BUTTON_DPAD_LEFT : D_PAD_NAME + " Left",
	JOY_BUTTON_DPAD_RIGHT : D_PAD_NAME + " Right",
	JOY_BUTTON_MISC1 : "Misc",
}

const JOYPAD_DPAD_NAMES : Dictionary = {
	JOY_BUTTON_DPAD_UP : D_PAD_NAME + " Up",
	JOY_BUTTON_DPAD_DOWN : D_PAD_NAME + " Down",
	JOY_BUTTON_DPAD_LEFT : D_PAD_NAME + " Left",
	JOY_BUTTON_DPAD_RIGHT : D_PAD_NAME + " Right",
}

const JOY_AXIS_NAMES : Dictionary = {
	JOY_AXIS_TRIGGER_LEFT: "Left Trigger",
	JOY_AXIS_TRIGGER_RIGHT: "Right Trigger",
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

static func is_joypad_event(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion

static func is_mouse_event(event: InputEvent) -> bool:
	return event is InputEventMouseButton or event is InputEventMouseMotion

static func is_screen_event(event: InputEvent) -> bool:
	return event is InputEventScreenDrag or event is InputEventScreenTouch

static func is_keyboard_event(event: InputEvent) -> bool:
	return event is InputEventKey

static func get_joypad_device_name_by_id(device_id : int) -> String:
	if device_id >= 0:
		var device_name = Input.get_joy_name(device_id)
		for device_key in SDL_DEVICE_NAMES:
			for keyword in SDL_DEVICE_NAMES[device_key]:
				if device_name.containsn(keyword):
					return device_key
	return DEVICE_GENERIC

static func get_joypad_device_name(event: InputEvent) -> String:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event.device == -1:
			return DEVICE_GENERIC
		var device_id = event.device
		return get_joypad_device_name_by_id(device_id)
	return DEVICE_GENERIC

static func get_input_device_name(event: InputEvent) -> String:
	if is_joypad_event(event):
		return DEVICE_JOYPAD
	if is_screen_event(event):
		return DEVICE_SCREEN
	if is_mouse_event(event):
		return DEVICE_MOUSE
	if is_keyboard_event(event):
		return DEVICE_KEYBOARD
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

static func get_joypad_event_button_name(event : InputEventJoypadButton, joypad_device_name : String) -> String:
	var joypad_button : String = ""
	if event.button_index in JOYPAD_DPAD_NAMES:
		joypad_button = JOYPAD_DPAD_NAMES[event.button_index]
	elif event.button_index < JOYPAD_BUTTON_NAME_MAP[joypad_device_name].size():
		joypad_button = JOYPAD_BUTTON_NAME_MAP[joypad_device_name][event.button_index]
	return joypad_button

static func get_event_device_text(event : InputEvent, joypad_device_name : String = "") -> String:
	if joypad_device_name.is_empty():
		joypad_device_name = get_joypad_device_name(event)
	if event is InputEventJoypadButton:
		var joypad_button : String = get_joypad_event_button_name(event, joypad_device_name)
		return "%s %s" % [joypad_device_name, joypad_button]
	if event is InputEventJoypadMotion:
		return "%s %s" % [joypad_device_name, get_text(event)]
	if event is InputEventMouseButton:
		if event.button_index < MOUSE_BUTTONS.size():
			var mouse_button : String = MOUSE_BUTTONS[event.button_index]
			return "%s %s" % [DEVICE_MOUSE, mouse_button]
	return get_text(event).capitalize()

static func get_action_device_event(action_name : StringName, input_device_name : String, input_number : int = 0) -> InputEvent:
	var input_events := InputMap.action_get_events(action_name)
	if input_events.size() < 1 : return
	var matching_events : Array[InputEvent]
	for input_event in input_events:
		if get_input_device_name(input_event) == input_device_name:
			matching_events.append(input_event)
	if not matching_events.is_empty():
		return matching_events[input_number % matching_events.size()]
	var first_event_device := get_input_device_name(input_events[0])
	return get_action_device_event(action_name, first_event_device, input_number)
