extends LevelListManager

func set_current_level_id(value : int) -> void:
	super.set_current_level_id(value)
	GameState.level_reached(value)

func get_current_level_id() -> int:
	current_level_id = GameState.get_current_level() if force_level == -1 else force_level
	return current_level_id

func _advance_level() -> bool:
	var _advanced := super._advance_level()
	GameState.set_current_level(current_level_id)
	return _advanced
