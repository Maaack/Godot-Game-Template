@tool
extends Node
class_name SceneLister
## Helper class for listing all the scenes in a directory.

## List of paths to scene files.
## Prefilled in the editor by selecting a directory.
@export var files : Array[String]
## Prefill files with any scenes in the directory.
@export_dir var directory : String :
	set(value):
		directory = value
		_refresh_files()

func _refresh_files():
	if not is_inside_tree() or directory.is_empty(): return
	var dir_access = DirAccess.open(directory)
	if dir_access:
		files.clear()
		for file in dir_access.get_files():
			if not file.ends_with(".tscn"):
				continue
			files.append(directory + "/" + file)
