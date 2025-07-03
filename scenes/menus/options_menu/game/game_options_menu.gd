extends Control

func _on_ResetGameControl_reset_confirmed() -> void:
	GlobalState.reset()


func _on_language_control_setting_changed(value: Variant) -> void:
	TranslationServer.set_locale(value)
