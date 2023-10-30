extends ConfirmationDialog

var last_input_event : InputEvent

func _record_input_event(event : InputEvent):
	last_input_event = event
	dialog_text = event.as_text()
	get_ok_button().disabled = false

func _unhandled_input(event):
	if not visible:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		_record_input_event(event)

func _is_button_released(input_event : InputEvent) -> bool:
	return (input_event is InputEventMouseButton or input_event is InputEventJoypadButton) and input_event.is_released()

func _is_possible_button_trigger(input_event : InputEvent) -> bool:
	return (input_event is InputEventMouseButton and input_event.button_index == MOUSE_BUTTON_LEFT) or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_A)

func _input(event):
	if not visible:
		return
	if _is_button_released(event):
		if _is_possible_button_trigger(event):
			await(get_tree().create_timer(0.05).timeout)
		_record_input_event(event)
