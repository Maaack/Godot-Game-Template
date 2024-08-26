@tool
extends EditorPlugin

const PLUGIN_NAME = "File Snake Caser"
const PROJECT_SETTINGS_PATH = "file_snake_caser/"
const RESAVING_DELAY : float = 0.5

func _get_plugin_name():
	return PLUGIN_NAME

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func _delayed_saving():
	var timer: Timer = Timer.new()
	var callable := func():
		timer.stop()
		EditorInterface.get_resource_filesystem().scan()
		EditorInterface.save_all_scenes()
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(RESAVING_DELAY)

func _snake_case_directory(dir_path : String, ignore_file_extensions : PackedStringArray = []):
	if not dir_path.ends_with("/"):
		dir_path += "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var error : Error
		while file_name != "" and error == 0:
			var start_path = dir_path + file_name
			var end_path = dir_path + file_name.to_snake_case()
			var _match = start_path == end_path
			if file_name.get_extension() in ignore_file_extensions:
				file_name = dir.get_next()
				continue
			if dir.current_is_dir():
				if not dir.dir_exists(end_path) and not _match:
					error = dir.rename(start_path, end_path)
				_snake_case_directory(end_path, ignore_file_extensions)
			elif not _match:
				error = dir.rename(start_path, end_path)
			file_name = dir.get_next()
		if error:
			push_error("plugin error - renaming path: %s" % error)
	else:
		push_error("plugin error - accessing path: %s" % dir_path)

func _snake_case_root_directory(target_path : String):
	if not target_path.ends_with("/"):
		target_path += "/"
	_snake_case_directory(target_path, ["md", "txt", "cfg"])
	_delayed_saving()

func _show_folder_select():
	var select_scene : PackedScene = load(get_plugin_path() + "tool/folder_select_dialog.tscn")
	var select_instance : FileDialog = select_scene.instantiate()
	select_instance.dir_selected.connect(_snake_case_root_directory)
	add_child(select_instance)

func _enter_tree():
	add_tool_menu_item("Snake Case Files", _show_folder_select)

func _exit_tree():
	remove_tool_menu_item("Snake Case Files")
