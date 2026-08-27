@tool
extends ConfirmationPopupWindowPanel
## Scene to confirm a new input for an action name.

const LISTENING_TEXT : String = "Listening for input..."
const FOCUS_HERE_TEXT : String = "Focus here to assign inputs."
const CONFIRM_INPUT_TEXT : String = "Press again to confirm..."
const NO_INPUT_TEXT : String = "None"

enum InputConfirmation {
	SINGLE,
	DOUBLE,
	OK_BUTTON
}
## Confirmations required before a new input is accepted for an aciton.
@export var input_confirmation : InputConfirmation = InputConfirmation.SINGLE

@onready var input_label = %InputLabel
@onready var input_text_edit = %InputTextEdit
@onready var delay_timer = %DelayTimer

var last_input_event : InputEvent
var last_input_text : String
var listening : bool = false
var confirming : bool = false

func _record_input_event(event : InputEvent) -> void:
	last_input_text = InputEventHelper.get_text(event)
	if last_input_text.is_empty():
		return
	last_input_event = event
	input_label.text = last_input_text
	confirm_button.disabled = false
	get_viewport().set_input_as_handled()

func _is_recordable_input(event : InputEvent) -> bool:
	return event != null and \
		(event is InputEventKey or \
		event is InputEventMouseButton or \
		event is InputEventJoypadButton or \
		(event is InputEventJoypadMotion and \
		abs(event.axis_value) > 0.5)) and \
		event.is_pressed()

func _start_listening() -> void:
	input_text_edit.placeholder_text = LISTENING_TEXT
	listening = true
	delay_timer.start()

func _stop_listening() -> void:
	input_text_edit.placeholder_text = FOCUS_HERE_TEXT
	listening = false
	confirming = false

func _on_input_text_edit_focus_entered() -> void:
	_start_listening.call_deferred()

func _on_input_text_edit_focus_exited() -> void:
	_stop_listening()

func _focus_on_ok() -> void:
	confirm_button.grab_focus()

func _ready() -> void:
	super._ready()
	confirm_button.focus_neighbor_top = ^"../../../BodyMargin/VBoxContainer/InputTextEdit"
	close_button.focus_neighbor_top = ^"../../../BodyMargin/VBoxContainer/InputTextEdit"

func _input_matches_last(event : InputEvent) -> bool:
	return last_input_text == InputEventHelper.get_text(event)

func _is_mouse_input(event : InputEvent) -> bool:
	return event is InputEventMouse

func _input_confirms_choice(event : InputEvent) -> bool:
	return confirming and not _is_mouse_input(event) and _input_matches_last(event)

func _should_process_input_event(event : InputEvent) -> bool:
	return listening and _is_recordable_input(event) and delay_timer.is_stopped()

func _should_confirm_input_event(event : InputEvent) -> bool:
	return not _is_mouse_input(event)

func _confirm_choice() -> void:
	confirmed.emit()
	close()

func _process_input_event(event : InputEvent) -> void:
	if not _should_process_input_event(event):
		return
	if _input_confirms_choice(event):
		confirming = false
		if input_confirmation == InputConfirmation.DOUBLE:
			_confirm_choice()
		else:
			_focus_on_ok.call_deferred()
		return
	_record_input_event(event)
	if input_confirmation == InputConfirmation.SINGLE:
		_confirm_choice()
	if _should_confirm_input_event(event):
		confirming = true
		delay_timer.start()
		input_text_edit.placeholder_text = CONFIRM_INPUT_TEXT

func _on_input_text_edit_gui_input(event) -> void:
	input_text_edit.set_deferred("text", "")
	_process_input_event(event)

func _on_visibility_changed() -> void:
	super._on_visibility_changed()
	await draw
	if visible:
		if is_inside_tree():
			if input_label:
				if not text.strip_edges().is_empty():
					input_label.text = text
				else:
					input_label.text = NO_INPUT_TEXT
			if input_text_edit and input_text_edit.is_inside_tree():
				input_text_edit.grab_focus()
