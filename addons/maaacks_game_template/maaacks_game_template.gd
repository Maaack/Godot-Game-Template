@tool
extends EditorPlugin

const PLUGIN_NAME = "Maaack's Game Template"
const PROJECT_SETTINGS_PATH = "maaacks_game_template/"

const EXAMPLES_RELATIVE_PATH = "examples/"
const MAIN_SCENE_RELATIVE_PATH = "scenes/Opening/OpeningWithLogo.tscn"
const MAIN_SCENE_UPDATE_TEXT = "Current:\n%s\n\nNew:\n%s\n"
const OVERRIDE_RELATIVE_PATH = "installer/override.cfg"
const SCENE_LOADER_RELATIVE_PATH = "base/scenes/Autoloads/SceneLoader.tscn"
const UID_PREG_MATCH = r'uid="uid:\/\/[0-9a-z]+" '
const RESAVING_DELAY : float = 0.5
const REIMPORT_FILE_DELAY : float = 0.2
const OPEN_EDITOR_DELAY : float = 0.1

func _get_plugin_name():
	return PLUGIN_NAME

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func get_plugin_examples_path() -> String:
	return get_plugin_path() + EXAMPLES_RELATIVE_PATH

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
	var main_confirmation_scene : PackedScene = load(get_plugin_path() + "installer/MainSceneConfirmationDialog.tscn")
	var main_confirmation_instance : ConfirmationDialog = main_confirmation_scene.instantiate()
	main_confirmation_instance.dialog_text += MAIN_SCENE_UPDATE_TEXT % [current_main_scene, new_main_scene]
	main_confirmation_instance.confirmed.connect(_update_main_scene.bind(new_main_scene))
	add_child(main_confirmation_instance)

func _replace_file_contents(file_path : String, target_path : String):
	var extension : String = file_path.get_extension()
	if extension == "import":
		# skip import files
		return OK
	var file = FileAccess.open(file_path, FileAccess.READ)
	var regex = RegEx.new()
	regex.compile(UID_PREG_MATCH)
	if file == null:
		push_error("plugin error - null file: `%s`" % file_path)
		return
	var original_content = file.get_as_text()
	var replaced_content = regex.sub(original_content, "", true)
	replaced_content = replaced_content.replace(get_plugin_examples_path(), target_path)
	file.close()
	if replaced_content == original_content: return
	file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(replaced_content)
	file.close()

func _save_resource(resource_path : String, resource_destination : String, whitelisted_extensions : PackedStringArray = []) -> Error:
	var extension : String = resource_path.get_extension()
	if whitelisted_extensions.size() > 0:
		if not extension in whitelisted_extensions:
			return OK
	if extension == "import":
		# skip import files
		return OK
	var file_object = load(resource_path)
	if file_object is Resource:
		var possible_extensions = ResourceSaver.get_recognized_extensions(file_object)
		if possible_extensions.has(extension):
			return ResourceSaver.save(file_object, resource_destination, ResourceSaver.FLAG_CHANGE_PATH)
		else:
			return ERR_FILE_UNRECOGNIZED
	else:
		return ERR_FILE_UNRECOGNIZED
	return OK

func _delayed_reimporting_file(file_path : String):
	var timer: Timer = Timer.new()
	var callable := func():
		timer.stop()
		var file_system = EditorInterface.get_resource_filesystem()
		file_system.reimport_files([file_path])
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(REIMPORT_FILE_DELAY)

func _raw_copy_file_path(file_path : String, destination_path : String) -> Error:
	var dir := DirAccess.open("res://")
	var error := dir.copy(file_path, destination_path)
	if not error:
		EditorInterface.get_resource_filesystem().update_file(destination_path)
	return error

func _copy_override_file():
	var override_path : String = get_plugin_path() + OVERRIDE_RELATIVE_PATH
	_raw_copy_file_path(override_path, "res://"+override_path.get_file())

func _copy_file_path(file_path : String, destination_path : String, target_path : String, raw_copy_file_extensions : PackedStringArray = []) -> Error:
	if file_path.get_extension() in raw_copy_file_extensions:
		# Markdown file format
		return _raw_copy_file_path(file_path, destination_path)
	var error = _save_resource(file_path, destination_path)
	if error == ERR_FILE_UNRECOGNIZED:
		# Copy image files and other assets
		error = _raw_copy_file_path(file_path, destination_path)
		# Reimport image files to create new .import
		if not error:
			_delayed_reimporting_file(destination_path)
		return error
	if not error:
		_replace_file_contents(destination_path, target_path)
	return error

func _copy_directory_path(dir_path : String, target_path : String, raw_copy_file_extensions : PackedStringArray = []):
	if not dir_path.ends_with("/"):
		dir_path += "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var error : Error
		while file_name != "" and error == 0:
			var relative_path = dir_path.trim_prefix(get_plugin_examples_path())
			var destination_path = target_path + relative_path + file_name
			var full_file_path = dir_path + file_name
			if dir.current_is_dir():
				if not dir.dir_exists(destination_path):
					error = dir.make_dir(destination_path)
				_copy_directory_path(full_file_path, target_path, raw_copy_file_extensions)
			else:
				error = _copy_file_path(full_file_path, destination_path, target_path, raw_copy_file_extensions)
			file_name = dir.get_next()
		if error:
			push_error("plugin error - copying path: %s" % error)
	else:
		push_error("plugin error - accessing path: %s" % dir_path)

func _update_scene_loader_path(target_path : String):
	var file_path : String = get_plugin_path() + SCENE_LOADER_RELATIVE_PATH
	var file_text : String = FileAccess.get_file_as_string(file_path)
	var prefix : String = "loading_screen_path = \""
	var target_string =  prefix + get_plugin_path() + "base/"
	var replacing_string = prefix + target_path
	file_text = file_text.replace(target_string, replacing_string)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(file_text)
	file.close()

func _delayed_saving_and_check_main_scene(target_path : String):
	var timer: Timer = Timer.new()
	var callable := func():
		timer.stop()
		EditorInterface.save_all_scenes()
		_check_main_scene_needs_updating(target_path)
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(RESAVING_DELAY)

func _copy_to_directory(target_path : String):
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + "copy_path", target_path)
	ProjectSettings.save()
	if not target_path.ends_with("/"):
		target_path += "/"
	_copy_directory_path(get_plugin_examples_path(), target_path, ["md"])
	_update_scene_loader_path(target_path)
	_copy_override_file()
	_delayed_saving_and_check_main_scene(target_path)

func _open_path_dialog():
	var destination_scene : PackedScene = load(get_plugin_path() + "installer/DestinationDialog.tscn")
	var destination_instance : FileDialog = destination_scene.instantiate()
	destination_instance.dir_selected.connect(_copy_to_directory)
	destination_instance.canceled.connect(_check_main_scene_needs_updating.bind(get_plugin_examples_path()))
	add_child(destination_instance)

func _open_confirmation_dialog():
	var confirmation_scene : PackedScene = load(get_plugin_path() + "installer/CopyConfirmationDialog.tscn")
	var confirmation_instance : ConfirmationDialog = confirmation_scene.instantiate()
	confirmation_instance.confirmed.connect(_open_path_dialog)
	confirmation_instance.canceled.connect(_check_main_scene_needs_updating.bind(get_plugin_examples_path()))
	add_child(confirmation_instance)

func _show_plugin_dialogues():
	if ProjectSettings.has_setting(PROJECT_SETTINGS_PATH + "disable_plugin_dialogues") :
		if ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "disable_plugin_dialogues") :
			return
	_open_confirmation_dialog()
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + "disable_plugin_dialogues", true)
	ProjectSettings.save()

func _resave_if_recently_opened():
	if Engine.get_physics_frames() == 0:
		var timer: Timer = Timer.new()
		var callable := func():
			if Engine.get_frames_per_second() >= 10:
				timer.stop()
				EditorInterface.save_scene()
				timer.queue_free()
		timer.timeout.connect(callable)
		add_child(timer)
		timer.start(OPEN_EDITOR_DELAY)

func _enter_tree():
	add_autoload_singleton("AppConfig", get_plugin_path() + "base/scenes/Autoloads/AppConfig.tscn")
	add_autoload_singleton("SceneLoader", get_plugin_path() + "base/scenes/Autoloads/SceneLoader.tscn")
	add_autoload_singleton("ProjectMusicController", get_plugin_path() + "base/scenes/Autoloads/ProjectMusicController.tscn")
	add_autoload_singleton("ProjectUISoundController", get_plugin_path() + "base/scenes/Autoloads/ProjectUISoundController.tscn")
	add_tool_menu_item("Copy " + _get_plugin_name() + " Examples...", _open_path_dialog)
	_show_plugin_dialogues()
	_resave_if_recently_opened()

func _exit_tree():
	remove_autoload_singleton("AppConfig")
	remove_autoload_singleton("SceneLoader")
	remove_autoload_singleton("ProjectMusicController")
	remove_autoload_singleton("ProjectUISoundController")
	remove_tool_menu_item("Copy " + _get_plugin_name() + " Examples...",)
