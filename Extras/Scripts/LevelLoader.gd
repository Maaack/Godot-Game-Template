@tool
extends Node
class_name LevelLoader

@export var level_files : Array[String]
@export_dir var level_dir : String :
	set(value):
		level_dir = value
		if not is_inside_tree() or not Engine.is_editor_hint():
			return
		var dir_access = DirAccess.open(level_dir)
		if dir_access:
			level_files.clear()
			for file in dir_access.get_files():
				if not file.ends_with(".tscn"):
					continue
				level_files.append(level_dir + "/" + file)
				
@export_group("Debugging")
@export var force_level : int = -1

func get_current_level_file():
	if level_files.is_empty():
		push_error("level_files is empty")
		return
	var current_level = GameLevelLog.get_current_level() if force_level == -1 else force_level
	if current_level < 0 or current_level >= level_files.size():
		current_level = 0
	return level_files[current_level]

func increment_level():
	var current_level = GameLevelLog.get_current_level()
	current_level += 1
	if current_level >= level_files.size():
		current_level = 0
	GameLevelLog.level_reached(current_level)
	
