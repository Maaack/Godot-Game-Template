extends LevelManager

func set_current_level_path(value : String) -> void:
	super.set_current_level_path(value)
	GameState.set_current_level_path(value)

func set_checkpoint_level_path(value : String) -> void:
	super.set_checkpoint_level_path(value)
	GameState.set_checkpoint_level_path(value)

func get_checkpoint_level_path() -> String:
	var state_level_path := GameState.get_checkpoint_level_path()
	if not state_level_path.is_empty():
		return state_level_path
	return super.get_checkpoint_level_path()
