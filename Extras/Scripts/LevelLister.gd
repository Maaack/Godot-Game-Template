@tool
extends SceneLister
class_name LevelLister

@export_group("Debugging")
@export var force_level : int = -1

func get_current_level_file():
	if files.is_empty():
		push_error("files is empty")
		return
	var current_level = GameLevelLog.get_current_level() if force_level == -1 else force_level
	if current_level < 0 or current_level >= files.size():
		current_level = 0
	return files[current_level]

func increment_level():
	var current_level = GameLevelLog.get_current_level()
	current_level += 1
	if current_level >= files.size():
		current_level = 0
	GameLevelLog.level_reached(current_level)
	
