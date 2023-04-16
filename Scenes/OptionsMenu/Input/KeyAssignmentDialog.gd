extends ConfirmationDialog

var last_input_event : InputEventWithModifiers

func _input(event):
	if not visible:
		return
	if event is InputEventKey:
		last_input_event = event
		dialog_text = OS.get_keycode_string(event.get_keycode_with_modifiers())
		get_ok_button().disabled = false
