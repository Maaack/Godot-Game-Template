extends Control
## Node for providing players with input hints for specific actions.

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
## Delay before incrementing input_number.
@export var input_cycle_delay : float = 0.0
## Show input hints exlusively for the last detected device (Keyboard or Joypad)
@export var last_device_specific : bool = true
@export_group("Icons")
## Reference to an InputIconMapper in the scene tree.
@export var input_icon_mapper : InputIconMapper
## The expand mode set to the icon, if available.
@export var expand_mode : TextureRect.ExpandMode :
	set(value):
		expand_mode = value
		if is_inside_tree():
			_icon_texture_rect.expand_mode = expand_mode

var _last_input_device : String = ""

@onready var _name_label : Label = %Name
@onready var _icon_texture_rect : TextureRect = %Icon
@onready var _cycle_delay_timer : Timer = %CycleDelay

func _get_input_event() -> InputEvent:
	if last_device_specific:
		return InputEventHelper.get_action_device_event(action_name, _last_input_device, input_number)
	var input_events := InputMap.action_get_events(action_name)
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

func _input(event):
	if not last_device_specific: return
	var input_device_name = InputEventHelper.get_input_device_name(event)
	if input_device_name != _last_input_device:
		_last_input_device = input_device_name
		_refresh()

func _on_timer_timeout():
	input_number += 1
