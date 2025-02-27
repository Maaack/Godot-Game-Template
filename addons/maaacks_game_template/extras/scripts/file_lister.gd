@tool
extends Node
class_name FileLister
## Helper class for listing all the scenes in a directory.

## List of paths to scene files.
## Prefilled in the editor by selecting a directory.
@export var files : Array[String]
## Prefill files with any scenes in the directory.
@export_dir var directory : String :
	set(value):
		directory = value
		_refresh_files()
@export_tool_button("Update") var _refresh_files_action = _refresh_files

@export_group("Constraints")
@export var search : String
@export var filter : String

@export_subgroup("Advanced Search")
@export var begins_with : String
@export var ends_with : String


func _refresh_files():
	if not is_inside_tree() or directory.is_empty(): return
	var dir_access = DirAccess.open(directory)
	if dir_access:
		files.clear()
		for file in dir_access.get_files():
			if (not search.is_empty()) and (not file.contains(search)):
				continue
			if (not filter.is_empty()) and (file.contains(filter)):
				continue
			if (not begins_with.is_empty()) and (not file.begins_with(begins_with)):
				continue
			if (not ends_with.is_empty()) and (not file.ends_with(ends_with)):
				continue
			files.append(directory + "/" + file)
