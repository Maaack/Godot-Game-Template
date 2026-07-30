extends Control
## Node for providing players with input hints for specific actions.

const KEYBOARD_AND_MOUSE := [InputEventHelper.DEVICE_KEYBOARD, InputEventHelper.DEVICE_MOUSE, InputEventHelper.DEVICE_GENERIC]

## Name of the input action.
@export var action_name : StringName :
	set(value):
		action_name = value
		if is_inside_tree():
			_refresh()
## Number of the input event for the input action.
@export var input_number : int = 0 :
	set(value):
		input_number = value
		if is_inside_tree():
			_refresh()
## Delay before incrementing input_number, and displaying the next input action.
@export var input_cycle_delay : float = 0.0
@export_group("Device Specific")
## Show input hints exlusively for the last detected device (Keyboard or Joypad)
@export var last_device_specific : bool = true
## Combines displaying the inputs for keyboard and mouse.
@export var combine_keyboard_and_mouse : bool = true
## Delay before refreshing current device.
@export var device_update_delay : float = 0.5
@export_group("Icons")
## Reference to an InputIconMapper in the scene tree.
@export var input_icon_mapper : InputIconMapper
## The expand mode set to the icon, if available.
@export var expand_mode : TextureRect.ExpandMode :
	set(value):
		expand_mode = value
		if is_inside_tree():
			_icon_texture_rect.expand_mode = expand_mode

var _last_input_device : String = InputEventHelper.DEVICE_GENERIC
var _can_update_last_device : bool = false

@onready var _name_label : Label = %Name
@onready var _icon_texture_rect : TextureRect = %Icon
@onready var _cycle_delay_timer : Timer = %CycleDelay
@onready var _update_delay_timer = %UpdateDelay

func _get_input_event() -> InputEvent:
	var input_events : Array
	if not last_device_specific:
		input_events = InputMap.action_get_events(action_name)
	elif combine_keyboard_and_mouse and _last_input_device in KEYBOARD_AND_MOUSE:
		var _input_keyboard := InputEventHelper.get_action_device_event(action_name, InputEventHelper.DEVICE_KEYBOARD, input_number)
		var _input_mouse := InputEventHelper.get_action_device_event(action_name, InputEventHelper.DEVICE_MOUSE, input_number)
		input_events.append(_input_keyboard)
		if _input_keyboard != _input_mouse:
			input_events.append(_input_mouse)
	else:
		return InputEventHelper.get_action_device_event(action_name, _last_input_device, input_number)
	return input_events[input_number % input_events.size()]

func _refresh() -> void:
	var input_event := _get_input_event()
	var icon_texture : Texture
	if input_icon_mapper:
		icon_texture = input_icon_mapper.get_icon(input_event)
	if icon_texture:
		_icon_texture_rect.texture = icon_texture
		_name_label.text = ""
	else:
		_icon_texture_rect.texture = null
		_name_label.text = InputEventHelper.get_text(input_event)

func _ready() -> void:
	_refresh.call_deferred()
	expand_mode = expand_mode
	if input_icon_mapper:
		input_icon_mapper.joypad_device_changed.connect(_refresh)
	if input_cycle_delay > 0:
		_cycle_delay_timer.start(input_cycle_delay)
	if last_device_specific:
		_update_delay_timer.start(device_update_delay)

func _input(event):
	if (not last_device_specific) or (not _can_update_last_device):
		return
	var _input_device : String = InputEventHelper.get_input_device_name(event)
	if _input_device != InputEventHelper.DEVICE_GENERIC and _input_device != _last_input_device:
		_last_input_device = _input_device
		_can_update_last_device = false
		_update_delay_timer.start(device_update_delay)
		_refresh()

func _on_cycle_delay_timeout():
	input_number += 1
	_refresh()

func _on_update_delay_timeout():
	_can_update_last_device = true
