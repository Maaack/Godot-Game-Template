extends ConfirmationDialog

const LISTENING_TEXT : String = "Listening for input..."
const FOCUS_HERE_TEXT : String = "Focus here to assign inputs."
const NO_INPUT_TEXT : String = "None"

var last_input_event : InputEvent
var last_input_text : String
var listening : bool = false

func _record_input_event(event : InputEvent):
	last_input_text = InputEventHelper.get_text(event)
	if last_input_text.is_empty():
		return
	last_input_event = event
	%InputLabel.text = last_input_text
	get_ok_button().disabled = false

func _is_recordable_input(event : InputEvent):
	return event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.5)

func _start_listening():
	%InputTextEdit.placeholder_text = LISTENING_TEXT
	listening = true

func _stop_listening():
	%InputTextEdit.placeholder_text = FOCUS_HERE_TEXT
	listening = false

func _on_text_edit_focus_entered():
	_start_listening.call_deferred()

func _on_input_text_edit_focus_exited():
	_stop_listening()

func _on_input_text_edit_gui_input(event : InputEvent):
	%InputTextEdit.text = ""
	if not listening or event == null or event.is_released():
		return
	if _is_recordable_input(event):
		_record_input_event(event)

func _on_visibility_changed():
	if visible:
		%InputLabel.text = NO_INPUT_TEXT
		%InputTextEdit.grab_focus()
