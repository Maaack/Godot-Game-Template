extends HBoxContainer

const RESET_STRING := "Reset Game:"
const CONFIRM_STRING := "Confirm Reset:"

signal reset_confirmed

func _on_cancel_button_pressed():
	%CancelButton.hide()
	%ConfirmButton.hide()
	%ResetButton.show()
	%ResetButton.grab_focus()
	%ResetLabel.text = RESET_STRING

func _on_reset_button_pressed():
	%CancelButton.show()
	%ConfirmButton.show()
	%CancelButton.grab_focus()
	%ResetButton.hide()
	%ResetLabel.text = CONFIRM_STRING

func _on_confirm_button_pressed():
	reset_confirmed.emit()
	get_tree().paused = false
	SceneLoader.reload_current_scene()
