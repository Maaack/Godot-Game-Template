@tool
extends EditorPlugin

const EXAMPLE_DIRECTORY_PATH = "res://addons/maaacks_game_template/examples/"
const UID_PREG_MATCH = r'uid="uid:\/\/[0-9a-z]+" '
const MAIN_SCENE_RELATIVE_PATH = "scenes/Opening/OpeningWithLogo.tscn"
const MAIN_SCENE_UPDATE_TEXT = "Current:\n%s\n\nNew:\n%s\n"

func _update_main_scene(main_scene_path : String):
	ProjectSettings.set_setting("application/run/main_scene", main_scene_path)
	ProjectSettings.save()

func _check_main_scene_needs_updating(target_path : String):
	var current_main_scene_path = ProjectSettings.get_setting("application/run/main_scene", "")
	var new_main_scene_path = target_path + MAIN_SCENE_RELATIVE_PATH
	if new_main_scene_path == current_main_scene_path:
		return
	_open_main_scene_confirmation_dialog(current_main_scene_path, new_main_scene_path)

func _open_main_scene_confirmation_dialog(current_main_scene : String, new_main_scene : String):
	var main_confirmation_scene : PackedScene = load("res://addons/maaacks_game_template/installer/MainSceneConfirmationDialog.tscn")
	var main_confirmation_instance : ConfirmationDialog = main_confirmation_scene.instantiate()
	main_confirmation_instance.dialog_text += MAIN_SCENE_UPDATE_TEXT % [current_main_scene, new_main_scene]
	main_confirmation_instance.confirmed.connect(_update_main_scene.bind(new_main_scene))
	add_child(main_confirmation_instance)

func _replace_file_contents(file_path : String, target_path : String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var regex = RegEx.new()
	regex.compile(UID_PREG_MATCH)
	if file == null:
		push_error("plugin error - null file: `%s`" % file_path)
		return
	var original_content = file.get_as_text()
	var replaced_content = regex.sub(original_content, "", true)
	replaced_content = replaced_content.replace(EXAMPLE_DIRECTORY_PATH, target_path)
	file.close()
	if replaced_content == original_content: return
	file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(replaced_content)
	file.close()

func _save_resource(resource_path : String, resource_destination : String, whitelisted_extensions : PackedStringArray = []) -> Error:
	var file_object = load(resource_path)
	var extension : String = resource_path.get_extension()
	if whitelisted_extensions.size() > 0:
		if not extension in whitelisted_extensions:
			return OK
	if file_object is Resource:
		var possible_extensions = ResourceSaver.get_recognized_extensions(file_object)
		if possible_extensions.has(extension):
			return ResourceSaver.save(file_object, resource_destination, ResourceSaver.FLAG_CHANGE_PATH)
		else:
			return ERR_FILE_UNRECOGNIZED
	return OK

func _resave_resources(dir_path : String, whitelisted_extensions : PackedStringArray = []):
	if not dir_path.ends_with("/"):
		dir_path += "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var error : Error
		while file_name != "" and error == 0:
			var full_file_path = dir_path + file_name
			if dir.current_is_dir():
				_resave_resources(full_file_path, whitelisted_extensions)
			elif not file_name.ends_with(".import"):
				error = _save_resource(full_file_path, full_file_path, whitelisted_extensions)
			file_name = dir.get_next()
		if error:
			push_error("plugin error - resaving resource: %s" % error)
	else:
		push_error("plugin error - accessing path: %s" % dir_path)

func _copy_file_path(file_path : String, destination_path : String, target_path : String) -> Error:
	var error = _save_resource(file_path, destination_path)
	if not error:
		_replace_file_contents(destination_path, target_path)
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
	ProjectSettings.set_setting("maaacks_game_template/copy_path", target_path)
	ProjectSettings.save()
	if not target_path.ends_with("/"):
		target_path += "/"
	_copy_directory_path(EXAMPLE_DIRECTORY_PATH, target_path)
	_resave_resources(target_path, ["tres", "tscn"])
	_check_main_scene_needs_updating(target_path)

func _open_path_dialog():
	var destination_scene : PackedScene = load("res://addons/maaacks_game_template/installer/DestinationDialog.tscn")
	var destination_instance : FileDialog = destination_scene.instantiate()
	destination_instance.dir_selected.connect(_copy_to_directory)
	add_child(destination_instance)

func _open_confirmation_dialog():
	var confirmation_scene : PackedScene = load("res://addons/maaacks_game_template/installer/CopyConfirmationDialog.tscn")
	var confirmation_instance : ConfirmationDialog = confirmation_scene.instantiate()
	confirmation_instance.confirmed.connect(_open_path_dialog)
	confirmation_instance.canceled.connect(_check_main_scene_needs_updating.bind(EXAMPLE_DIRECTORY_PATH))
	add_child(confirmation_instance)

func _show_plugin_dialogues():
	if ProjectSettings.has_setting("maaacks_game_template/disable_plugin_dialogues") :
		if ProjectSettings.get_setting("maaacks_game_template/disable_plugin_dialogues") :
			return
	_open_confirmation_dialog()
	ProjectSettings.set_setting("maaacks_game_template/disable_plugin_dialogues", true)
	ProjectSettings.save()

func _enter_tree():
	add_autoload_singleton("AppConfig", "res://addons/maaacks_game_template/base/scenes/Autoloads/AppConfig.tscn")
	add_autoload_singleton("SceneLoader", "res://addons/maaacks_game_template/base/scenes/Autoloads/SceneLoader.tscn")
	add_autoload_singleton("ProjectMusicController", "res://addons/maaacks_game_template/base/scenes/Autoloads/ProjectMusicController.tscn")
	add_autoload_singleton("ProjectUISoundController", "res://addons/maaacks_game_template/base/scenes/Autoloads/ProjectUISoundController.tscn")
	_show_plugin_dialogues()

func _exit_tree():
	remove_autoload_singleton("AppConfig")
	remove_autoload_singleton("SceneLoader")
	remove_autoload_singleton("ProjectMusicController")
	remove_autoload_singleton("ProjectUISoundController")
