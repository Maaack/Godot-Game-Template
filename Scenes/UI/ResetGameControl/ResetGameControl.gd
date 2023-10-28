extends HBoxContainer

signal reset_confirmed


func _on_ResetButton_pressed():
	$ConfirmResetDialog.popup_centered()
	$ResetButton.disabled = true

func _on_ConfirmResetDialog_confirmed():
	emit_signal("reset_confirmed")

func _on_confirm_reset_dialog_canceled():
	$ResetButton.disabled = false
