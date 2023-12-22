@tool
extends Node
class_name SceneLister

@export var files : Array[String]
@export_dir var directory : String :
	set(value):
		directory = value
		if not is_inside_tree() or not Engine.is_editor_hint():
			return
		var dir_access = DirAccess.open(directory)
		if dir_access:
			files.clear()
			for file in dir_access.get_files():
				if not file.ends_with(".tscn"):
					continue
				files.append(directory + "/" + file)
