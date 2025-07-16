extends LevelManager

func set_current_level_path(value : String) -> void:
	super.set_current_level_path(value)
	GameState.set_current_level(value)
	GameState.get_level_state(value)

func get_current_level_path() -> String:
	var state_level_path := GameState.get_current_level_path()
	if not state_level_path.is_empty():
		current_level_path = state_level_path
	return super.get_current_level_path()

func _advance_level() -> bool:
	var _advanced := super._advance_level()
	if _advanced:
		GameState.level_reached(current_level_path)
	return _advanced
