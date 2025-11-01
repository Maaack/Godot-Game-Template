@tool
extends ConfirmationOverlaidWindow
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

var last_input_event : InputEvent
var last_input_text : String
var listening : bool = false
var confirming : bool = false

func _record_input_event(event : InputEvent) -> void:
	last_input_text = InputEventHelper.get_text(event)
	if last_input_text.is_empty():
		return
	last_input_event = event
	%InputLabel.text = last_input_text
	confirm_button.disabled = false

func _is_recordable_input(event : InputEvent) -> bool:
	return event != null and \
		(event is InputEventKey or \
		event is InputEventMouseButton or \
		event is InputEventJoypadButton or \
		(event is InputEventJoypadMotion and \
		abs(event.axis_value) > 0.5)) and \
		event.is_pressed()

func _start_listening() -> void:
	%InputTextEdit.placeholder_text = LISTENING_TEXT
	listening = true
	%DelayTimer.start()

func _stop_listening() -> void:
	%InputTextEdit.placeholder_text = FOCUS_HERE_TEXT
	listening = false
	confirming = false

func _on_input_text_edit_focus_entered() -> void:
	_start_listening.call_deferred()

func _on_input_text_edit_focus_exited() -> void:
	_stop_listening()

func _focus_on_ok() -> void:
	confirm_button.grab_focus()

func _ready() -> void:
	confirm_button.focus_neighbor_top = ^"../../../VBoxContainer/InputTextEdit"
	close_button.focus_neighbor_top = ^"../../../VBoxContainer/InputTextEdit"
	super._ready()

func _input_matches_last(event : InputEvent) -> bool:
	return last_input_text == InputEventHelper.get_text(event)

func _is_mouse_input(event : InputEvent) -> bool:
	return event is InputEventMouse

func _input_confirms_choice(event : InputEvent) -> bool:
	return confirming and not _is_mouse_input(event) and _input_matches_last(event)

func _should_process_input_event(event : InputEvent) -> bool:
	return listening and _is_recordable_input(event) and %DelayTimer.is_stopped()

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
		%DelayTimer.start()
		%InputTextEdit.placeholder_text = CONFIRM_INPUT_TEXT

func _on_input_text_edit_gui_input(event) -> void:
	%InputTextEdit.set_deferred("text", "")
	_process_input_event(event)

func _on_visibility_changed() -> void:
	super._on_visibility_changed()
	if visible:
		if not text.strip_edges().is_empty():
			%InputLabel.text = text
		else:
			%InputLabel.text = NO_INPUT_TEXT
		%InputTextEdit.grab_focus()
