@tool
extends EditorPlugin

const EXAMPLE_DIRECTORY_PATH = "res://addons/maaacks_game_template/examples/"
const MAIN_SCENE_RELATIVE_PATH = "scenes/Opening/OpeningWithLogo.tscn"

func _update_main_scene(main_scene_path : String):
	ProjectSettings.set_setting("application/run/main_scene", main_scene_path)
	ProjectSettings.save()

func _open_main_scene_confirmation_dialog(target_path : String):
	var main_confirmation_scene : PackedScene = load("res://addons/maaacks_game_template/installer/MainSceneConfirmationDialog.tscn")
	var main_confirmation_instance : ConfirmationDialog = main_confirmation_scene.instantiate()
	var main_scene_path = target_path + MAIN_SCENE_RELATIVE_PATH
	main_confirmation_instance.confirmed.connect(_update_main_scene.bind(main_scene_path))
	add_child(main_confirmation_instance)

func _replace_file_content_example_path(file_path : String, target_path : String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("plugin error - null file: `%s`" % file_path)
		return
	var original_content = file.get_as_text()
	var replaced_content = original_content.replace(EXAMPLE_DIRECTORY_PATH, target_path)
	if replaced_content == original_content: return
	file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(replaced_content)

func _copy_file_path(file_path : String, destination_path : String, target_path : String) -> Error:
	var file_object = load(file_path)
	var extension : String = file_path.get_extension()
	var error : Error
	if file_object is Resource:
		var possible_extensions = ResourceSaver.get_recognized_extensions(file_object)
		if possible_extensions.has(extension):
			error = ResourceSaver.save(file_object, destination_path, ResourceSaver.FLAG_CHANGE_PATH)
			_replace_file_content_example_path(destination_path, target_path)
	return error

func _copy_directory_path(dir_path : String, target_path : String):
	if not dir_path.ends_with("/"):
		dir_path += "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var error : Error
		while file_name != "" and error == 0:
			var relative_path = dir_path.trim_prefix(EXAMPLE_DIRECTORY_PATH)
			var destination_path = target_path + relative_path + file_name
			var full_file_path = dir_path + file_name
			if dir.current_is_dir():
				error = dir.make_dir(destination_path)
				_copy_directory_path(full_file_path, target_path)
			elif not file_name.ends_with(".import"):
				error = _copy_file_path(full_file_path, destination_path, target_path)
			file_name = dir.get_next()
		if error:
			push_error("plugin error - copying path: %s" % error)
	else:
		push_error("plugin error - accessing path: %s" % dir_path)

func _copy_to_directory(target_path : String):
	if not target_path.ends_with("/"):
		target_path += "/"
	_copy_directory_path(EXAMPLE_DIRECTORY_PATH, target_path)
	_open_main_scene_confirmation_dialog(target_path)

func _open_path_dialog():
	var destination_scene : PackedScene = load("res://addons/maaacks_game_template/installer/DestinationDialog.tscn")
	var destination_instance : FileDialog = destination_scene.instantiate()
	destination_instance.dir_selected.connect(_copy_to_directory)
	add_child(destination_instance)

func _open_confirmation_dialog():
	var confirmation_scene : PackedScene = load("res://addons/maaacks_game_template/installer/CopyConfirmationDialog.tscn")
	var confirmation_instance : ConfirmationDialog = confirmation_scene.instantiate()
	confirmation_instance.confirmed.connect(_open_path_dialog)
	add_child(confirmation_instance)

func _disable_first_time():
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("maaacks_game_template/enabled_first_time") :
		settings.set_setting("maaacks_game_template/enabled_first_time", false)
	
func _enable_first_time():
	var settings = EditorInterface.get_editor_settings()
	if settings.has_setting("maaacks_game_template/enabled_first_time") :
		if settings.get_setting("maaacks_game_template/enabled_first_time") : 
			return
	settings.set_setting("maaacks_game_template/enabled_first_time", true)
	_open_confirmation_dialog()

func _enter_tree():
	add_autoload_singleton("AppConfig", "res://addons/maaacks_game_template/base/scenes/Autoloads/AppConfig.tscn")
	add_autoload_singleton("SceneLoader", "res://addons/maaacks_game_template/base/scenes/Autoloads/SceneLoader.tscn")
	add_autoload_singleton("ProjectMusicController", "res://addons/maaacks_game_template/base/scenes/Autoloads/ProjectMusicController.tscn")
	add_autoload_singleton("ProjectUISoundController", "res://addons/maaacks_game_template/base/scenes/Autoloads/ProjectUISoundController.tscn")
	_enable_first_time()

func _exit_tree():
	remove_autoload_singleton("AppConfig")
	remove_autoload_singleton("SceneLoader")
	remove_autoload_singleton("ProjectMusicController")
	remove_autoload_singleton("ProjectUISoundController")
	_disable_first_time()
