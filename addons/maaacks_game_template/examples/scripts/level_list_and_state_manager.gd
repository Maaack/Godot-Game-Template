@tool
extends LevelListManager

func set_current_level_id(value : int) -> void:
	super.set_current_level_id(value)
	if value < files.size():
		GameStateExample.set_current_level(files[value])

func get_current_level_id() -> int:
	var found_level_id : int = max(files.find(GameStateExample.get_current_level_path()), 0)
	current_level_id = found_level_id if force_level == -1 else force_level
	return current_level_id

func _advance_level() -> bool:
	var _advanced := super._advance_level()
	if _advanced:
		GameStateExample.level_reached(files[current_level_id])
	return _advanced
