extends ConfirmationDialog

const LISTENING_TEXT : String = "Listening for input..."
const FOCUS_HERE_TEXT : String = "Focus here to assign inputs."
const CONFIRM_INPUT_TEXT : String = "Press again to confirm..."
const NO_INPUT_TEXT : String = "None"

var last_input_event : InputEvent
var last_input_text : String
var listening : bool = false
var confirming : bool = false

func _record_input_event(event : InputEvent):
	last_input_text = InputEventHelper.get_text(event)
	if last_input_text.is_empty():
		return
	last_input_event = event
	%InputLabel.text = last_input_text
	get_ok_button().disabled = false

func _is_recordable_input(event : InputEvent):
	return event != null and \
		(event is InputEventKey or \
		event is InputEventMouseButton or \
		event is InputEventJoypadButton or \
		(event is InputEventJoypadMotion and \
		abs(event.axis_value) > 0.5)) and \
		event.is_pressed()

func _start_listening():
	%InputTextEdit.placeholder_text = LISTENING_TEXT
	listening = true
	%DelayTimer.start()

func _stop_listening():
	%InputTextEdit.placeholder_text = FOCUS_HERE_TEXT
	listening = false
	confirming = false

func _on_text_edit_focus_entered():
	_start_listening.call_deferred()

func _on_input_text_edit_focus_exited():
	_stop_listening()

func _focus_on_ok():
	get_ok_button().grab_focus()

func _ready():
	get_ok_button().focus_neighbor_top = ^"../../%InputTextEdit"
	get_cancel_button().focus_neighbor_top = ^"../../%InputTextEdit"

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

func _process_input_event(event : InputEvent):
	if not _should_process_input_event(event):
		return
	if _input_confirms_choice(event):
		confirming = false
		_focus_on_ok.call_deferred()
		return
	_record_input_event(event)
	if _should_confirm_input_event(event):
		confirming = true
		%DelayTimer.start()
		%InputTextEdit.placeholder_text = CONFIRM_INPUT_TEXT

func _on_input_text_edit_gui_input(event):
	%InputTextEdit.set_deferred("text", "")
	_process_input_event(event)

func _on_visibility_changed():
	if visible:
		%InputLabel.text = NO_INPUT_TEXT
		%InputTextEdit.grab_focus()
