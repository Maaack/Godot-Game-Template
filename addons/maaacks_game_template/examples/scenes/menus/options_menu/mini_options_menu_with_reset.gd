extends MiniOptionsMenu

func _on_reset_game_control_reset_confirmed() -> void:
	GlobalState.reset()
