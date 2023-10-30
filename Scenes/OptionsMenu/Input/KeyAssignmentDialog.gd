extends ConfirmationDialog

var last_input_event : InputEventWithModifiers

func _record_key_event(event : InputEventKey):
	last_input_event = event
	dialog_text = event.as_text_keycode()
	get_ok_button().disabled = false

func _record_mouse_event(event : InputEventMouseButton):
	last_input_event = event
	dialog_text = event.as_text()
	get_ok_button().disabled = false

func _unhandled_input(event):
	if not visible:
		return
	if event is InputEventKey:
		_record_key_event(event)
	elif event is InputEventMouseButton and event.is_released():
		_record_mouse_event(event)

func _input(event):
	if not visible:
		return
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			await(get_tree().create_timer(0.05).timeout)
		_record_mouse_event(event)
