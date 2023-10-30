extends ConfirmationDialog

var last_input_event : InputEventWithModifiers

func _record_mouse_event(event : InputEventMouseButton):
	last_input_event = event
	match(event.button_index):
		MOUSE_BUTTON_LEFT:
			dialog_text = "Left Mouse Button"
		MOUSE_BUTTON_RIGHT:
			dialog_text = "Right Mouse Button"
		MOUSE_BUTTON_MIDDLE:
			dialog_text = "Middle Mouse Button"
		MOUSE_BUTTON_WHEEL_UP:
			dialog_text = "Up Mouse Wheel"
		MOUSE_BUTTON_WHEEL_DOWN:
			dialog_text = "Down Mouse Wheel"
		MOUSE_BUTTON_WHEEL_LEFT:
			dialog_text = "Left Mouse Wheel"
		MOUSE_BUTTON_WHEEL_RIGHT:
			dialog_text = "Right Mouse Wheel"
		MOUSE_BUTTON_XBUTTON1:
			dialog_text = "X1 Mouse Button"
		MOUSE_BUTTON_XBUTTON2:
			dialog_text = "X2 Mouse Button"
	get_ok_button().disabled = false

func _unhandled_input(event):
	if not visible:
		return
	if event is InputEventKey:
		last_input_event = event
		dialog_text = OS.get_keycode_string(event.get_keycode_with_modifiers())
		get_ok_button().disabled = false
	elif event is InputEventMouseButton and event.is_released():
		_record_mouse_event(event)

func _input(event):
	if not visible:
		return
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			await(get_tree().create_timer(0.05).timeout)
		_record_mouse_event(event)
