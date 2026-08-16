@tool
class_name MaaacksGameTemplatePlugin
extends EditorPlugin

const PLUGIN_NAME = "Maaack's Game Template"
const PROJECT_SETTINGS_PATH = "maaacks_game_template/"
const PLUGIN_REPO_URL = "https://github.com/Maaack/Godot-Game-Template"
const EXAMPLES_RELATIVE_PATH = "examples/"
const MAIN_SCENE_RELATIVE_PATH = "scenes/opening/opening.tscn"
const OVERRIDE_RELATIVE_PATH = "installer/override.cfg"
const MAIN_MENU_RELATIVE_PATH = "scenes/menus/main_menu/main_menu.tscn"
const GAME_SCENE_RELATIVE_PATH = "scenes/game/game.tscn"
const ENDING_SCENE_RELATIVE_PATH = "scenes/end_credits/end_credits.tscn"
const SCENE_LOADER_RELATIVE_PATH = "base/nodes/autoloads/scene_loader/scene_loader.tscn"
const LOADING_SCREEN_SCENE_RELATIVE_PATH = "scenes/loading_screen/loading_screen.tscn"
const THEMES_DIRECTORY_RELATIVE_PATH = "resources/themes"
const WINDOW_OPEN_DELAY : float = 0.5
const RUNNING_CHECK_DELAY : float = 0.25
const OPEN_EDITOR_DELAY : float = 0.1
const MAX_PHYSICS_FRAMES_FROM_START : int = 60
const AVAILABLE_TRANSLATIONS : Array = ["en", "fr"]
const MAIN_MENU_SCENE_PATH_KEY = "main_menu_scene_path"
const GAME_SCENE_PATH_KEY = "game_scene_path"
const ENDING_SCENE_PATH_KEY = "ending_scene_path"
const SCENE_PATHS : Dictionary[String, String] = {
	MAIN_MENU_SCENE_PATH_KEY : MAIN_MENU_RELATIVE_PATH,
	GAME_SCENE_PATH_KEY : GAME_SCENE_RELATIVE_PATH,
	ENDING_SCENE_PATH_KEY : ENDING_SCENE_RELATIVE_PATH,
}
const CopyAndEdit = preload("installer/copy_and_edit_files.gd")

static var instance : MaaacksGameTemplatePlugin

var selected_theme : String

static func get_plugin_name() -> String:
	return PLUGIN_NAME

static func get_settings_path() -> String:
	return PROJECT_SETTINGS_PATH

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func get_plugin_examples_path() -> String:
	return get_plugin_path() + EXAMPLES_RELATIVE_PATH

func get_scene_loader_path() -> String:
	return get_plugin_path() + SCENE_LOADER_RELATIVE_PATH

func get_copy_path() -> String:
	var copy_path = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "copy_path", get_plugin_examples_path())
	if not copy_path.ends_with("/"):
		copy_path += "/"
	return copy_path

static func get_main_menu_path(override_path : String = "") -> String:
	if (not override_path.is_empty()) and FileAccess.file_exists(override_path):
		return override_path
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + MAIN_MENU_SCENE_PATH_KEY, override_path)

static func get_game_path(override_path : String = "") -> String:
	if (not override_path.is_empty()) and FileAccess.file_exists(override_path):
		return override_path
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + GAME_SCENE_PATH_KEY, override_path)

static func get_ending_scene_path(override_path : String = "") -> String:
	if (not override_path.is_empty()) and FileAccess.file_exists(override_path):
		return override_path
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + ENDING_SCENE_PATH_KEY, override_path)

func _on_theme_selected(theme_resource_path: String) -> void:
	selected_theme = theme_resource_path

func _update_gui_theme() -> void:
	if selected_theme.is_empty(): return
	ProjectSettings.set_setting("gui/theme/custom", selected_theme)
	ProjectSettings.save()

func _on_visibility_changed_to_hidden(dialog_window : Window) -> void:
	if dialog_window and dialog_window.is_inside_tree() and not dialog_window.visible:
		dialog_window.queue_free()

func open_theme_selection_dialog(target_path : String) -> void:
	selected_theme = ""
	var theme_selection_scene : PackedScene = load(get_plugin_path() + "installer/theme_selection_dialog.tscn")
	var theme_selection_instance : ConfirmationDialog = theme_selection_scene.instantiate()
	theme_selection_instance.confirmed.connect(_update_gui_theme)
	theme_selection_instance.theme_selected.connect(_on_theme_selected)
	theme_selection_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(theme_selection_instance))
	add_child(theme_selection_instance)
	var theme_directores : Array[String]
	theme_directores.append(target_path + THEMES_DIRECTORY_RELATIVE_PATH)
	theme_selection_instance.theme_directories = theme_directores

func open_setup_complete_dialog(_target_path : String) -> void:
	var setup_complete_scene : PackedScene = load(get_plugin_path() + "installer/setup_complete_dialog.tscn")
	var setup_complete_instance : AcceptDialog = setup_complete_scene.instantiate()
	setup_complete_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(setup_complete_instance))
	add_child(setup_complete_instance)

func _delayed_call_with_path(callable : Callable, target_path : String) -> void:
	var timer: Timer = Timer.new()
	var timer_callable := func():
		timer.stop()
		callable.call(target_path)
		timer.queue_free()
	timer.timeout.connect(timer_callable)
	add_child(timer)
	timer.start(WINDOW_OPEN_DELAY)

func _delayed_open_setup_complete_dialog(target_path : String) -> void:
	_delayed_call_with_path(open_setup_complete_dialog, target_path)

func _update_main_scene(target_path : String, main_scene_path : String) -> void:
	ProjectSettings.set_setting("application/run/main_scene", main_scene_path)
	ProjectSettings.save()
	_delayed_open_setup_complete_dialog(target_path)

func is_main_scene_set(target_path : String = get_copy_path()) -> bool:
	var current_main_scene_path = ProjectSettings.get_setting("application/run/main_scene", "")
	var new_main_scene_path = target_path + MAIN_SCENE_RELATIVE_PATH
	return current_main_scene_path == new_main_scene_path

func _check_main_scene_needs_updating(target_path : String) -> void:
	if not is_main_scene_set(target_path):
		open_main_scene_confirmation_dialog(target_path)
		return
	_delayed_open_setup_complete_dialog(target_path)

func open_main_scene_confirmation_dialog(target_path : String) -> void:
	var main_confirmation_scene : PackedScene = load(get_plugin_path() + "installer/main_scene_confirmation_dialog.tscn")
	var main_confirmation_instance : ConfirmationDialog = main_confirmation_scene.instantiate()
	var new_main_scene_path = target_path + MAIN_SCENE_RELATIVE_PATH
	if main_confirmation_instance.has_method(&"set_main_scene_text"):
		main_confirmation_instance.set_main_scene_text(new_main_scene_path)
	main_confirmation_instance.confirmed.connect(_update_main_scene.bind(target_path, new_main_scene_path))
	main_confirmation_instance.canceled.connect(_delayed_open_setup_complete_dialog.bind(target_path))
	main_confirmation_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(main_confirmation_instance))
	add_child(main_confirmation_instance)

func _open_play_opening_confirmation_dialog(target_path : String) -> void:
	var play_confirmation_scene : PackedScene = load(get_plugin_path() + "installer/play_opening_confirmation_dialog.tscn")
	var play_confirmation_instance : ConfirmationDialog = play_confirmation_scene.instantiate()
	play_confirmation_instance.confirmed.connect(_run_opening_scene.bind(target_path))
	play_confirmation_instance.canceled.connect(_check_main_scene_needs_updating.bind(target_path))
	play_confirmation_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(play_confirmation_instance))
	add_child(play_confirmation_instance)

func _open_delete_examples_confirmation_dialog(target_path : String) -> void:
	var delete_confirmation_scene : PackedScene = load(get_plugin_path() + "installer/delete_examples_confirmation_dialog.tscn")
	var delete_confirmation_instance : ConfirmationDialog = delete_confirmation_scene.instantiate()
	delete_confirmation_instance.confirmed.connect(_delete_source_examples_directory.bind(target_path))
	delete_confirmation_instance.canceled.connect(_check_main_scene_needs_updating.bind(target_path))
	delete_confirmation_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(delete_confirmation_instance))
	add_child(delete_confirmation_instance)

func open_delete_examples_short_confirmation_dialog() -> void:
	var delete_confirmation_scene : PackedScene = load(get_plugin_path() + "installer/delete_examples_short_confirmation_dialog.tscn")
	var delete_confirmation_instance : ConfirmationDialog = delete_confirmation_scene.instantiate()
	delete_confirmation_instance.confirmed.connect(_delete_source_examples_directory)
	delete_confirmation_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(delete_confirmation_instance))
	add_child(delete_confirmation_instance)

func _run_opening_scene(target_path : String) -> void:
	var opening_scene_path = target_path + MAIN_SCENE_RELATIVE_PATH
	EditorInterface.play_custom_scene(opening_scene_path)
	var timer: Timer = Timer.new()
	var callable := func() -> void:
		if EditorInterface.is_playing_scene(): return
		timer.stop()
		_delayed_call_with_path(_open_delete_examples_confirmation_dialog, target_path)
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(RUNNING_CHECK_DELAY)

func _delete_directory_recursive(dir_path : String) -> void:
	if not dir_path.ends_with("/"):
		dir_path += "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var error : Error
		while file_name != "" and error == 0:
			var relative_path = dir_path.trim_prefix(get_plugin_examples_path())
			var full_file_path = dir_path + file_name
			if dir.current_is_dir():
				_delete_directory_recursive(full_file_path)
			else:
				error = dir.remove(file_name)
			file_name = dir.get_next()
		if error:
			push_error("plugin error - deleting path: %s" % error)
	else:
		push_error("plugin error - accessing path: %s" % dir)
	dir.remove(dir_path)

func _delete_source_examples_directory(target_path : String = "") -> void:
	var examples_path = get_plugin_examples_path()
	var dir := DirAccess.open("res://")
	if dir.dir_exists(examples_path):
		_delete_directory_recursive(examples_path)
		EditorInterface.get_resource_filesystem().scan()
	if not target_path.is_empty():
		_check_main_scene_needs_updating(target_path)

func _raw_copy_file_path(file_path : String, destination_path : String) -> Error:
	var dir := DirAccess.open("res://")
	var error := dir.copy(file_path, destination_path)
	return error

func _copy_override_file() -> void:
	var override_path : String = get_plugin_path() + OVERRIDE_RELATIVE_PATH
	_raw_copy_file_path(override_path, "res://"+override_path.get_file())

func _set_project_paths(target_path : String, overwrite : bool = true) -> void:
	for key in SCENE_PATHS:
		if (not overwrite) and ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + key) != null:
			continue
		var relative_path = SCENE_PATHS[key]
		var full_path = target_path + relative_path
		ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + key, full_path)
	
func _set_default_project_paths() -> void:
	_set_project_paths(get_plugin_examples_path(), false)

func update_project_paths(target_path : String) -> void:
	_set_project_paths(target_path)
	update_autoload_paths(target_path)

func _update_scene_loader_path(target_path : String) -> void:
	var file_path : String = get_scene_loader_path()
	var file_text : String = FileAccess.get_file_as_string(file_path)
	var path_for_regex := LOADING_SCREEN_SCENE_RELATIVE_PATH.replace("/", "\\/").replace(".", "\\.")
	var regex := RegEx.create_from_string("loading_screen_path = \"(\\S*)%s\"" % path_for_regex)
	var replacement : String = "loading_screen_path = \"%s%s\"" % [target_path, LOADING_SCREEN_SCENE_RELATIVE_PATH]
	file_text = regex.sub(file_text, replacement)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(file_text)
	file.close()

func _add_translations() -> void:
	var dir := DirAccess.open("res://")
	var translations : PackedStringArray = ProjectSettings.get_setting("internationalization/locale/translations", [])
	for available_translation in AVAILABLE_TRANSLATIONS:
		var translation_path = get_plugin_path() + ("base/translations/menus_translations.%s.translation" % available_translation)
		if dir.file_exists(translation_path) and translation_path not in translations:
			translations.append(translation_path)
	ProjectSettings.set_setting("internationalization/locale/translations", translations)

func _are_all_project_paths_updated(target_path) -> bool:
	for key in SCENE_PATHS:
		var value : String = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + key, "")
		if not value == target_path + SCENE_PATHS[key]:
			return false
	return true

func _is_scene_loader_path_updated(target_path) -> bool:
	var file_text : String = FileAccess.get_file_as_string(get_scene_loader_path())
	var target_string = "loading_screen_path = \"" + get_plugin_examples_path()
	return !file_text.contains(target_string)

func are_project_paths_updated() -> bool:
	var copy_path := get_copy_path()
	if copy_path == get_plugin_examples_path(): return false
	return _is_scene_loader_path_updated(copy_path) and _are_all_project_paths_updated(copy_path)

func update_autoload_paths(target_path : String) -> void:
	_update_scene_loader_path(target_path)

func _on_completed_copy_to_directory(target_path : String) -> void:
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + "copy_path", target_path)
	ProjectSettings.save()
	update_project_paths(target_path)
	_copy_override_file()
	_open_play_opening_confirmation_dialog(target_path)

func are_examples_deleted() -> bool:
	var dir := DirAccess.open("res://")
	return not dir.dir_exists(get_plugin_examples_path())

func is_partially_installed() -> bool:
	var copy_path : String = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "copy_path")
	if copy_path.is_empty():
		# Installation not started
		return false
	if not are_examples_deleted():
		return true
	if not are_project_paths_updated():
		return true
	return false

func open_input_icons_dialog() -> void:
	var input_icons_scene : PackedScene = load(get_plugin_path() + "installer/kenney_input_prompts_installer.tscn")
	var input_icons_instance = input_icons_scene.instantiate()
	input_icons_instance.copy_dir_path = get_copy_path()
	add_child(input_icons_instance)

func open_copy_and_edit_dialog() -> void:
	var copy_and_edit_scene : PackedScene = load(get_plugin_path() + "installer/copy_and_edit_files.tscn")
	var copy_and_edit_instance : CopyAndEdit = copy_and_edit_scene.instantiate()
	copy_and_edit_instance.completed.connect(_on_completed_copy_to_directory)
	copy_and_edit_instance.canceled.connect(_check_main_scene_needs_updating.bind(get_copy_path()))
	add_child(copy_and_edit_instance)

func _open_confirmation_dialog() -> void:
	var confirmation_scene : PackedScene = load(get_plugin_path() + "installer/copy_confirmation_dialog.tscn")
	var confirmation_instance : ConfirmationDialog = confirmation_scene.instantiate()
	confirmation_instance.confirmed.connect(open_copy_and_edit_dialog)
	confirmation_instance.canceled.connect(_check_main_scene_needs_updating.bind(get_copy_path()))
	confirmation_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(confirmation_instance))
	add_child(confirmation_instance)

func _open_continue_setup_dialog() -> void:
	var confirmation_scene : PackedScene = load(get_plugin_path() + "installer/continue_setup_confirmation_dialog.tscn")
	var confirmation_instance : ConfirmationDialog = confirmation_scene.instantiate()
	confirmation_instance.confirmed.connect(open_setup_wizard)
	confirmation_instance.visibility_changed.connect(_on_visibility_changed_to_hidden.bind(confirmation_instance))
	add_child(confirmation_instance)

func open_setup_wizard() -> void:
	var setup_wizard_scene : PackedScene = load(get_plugin_path() + "installer/setup_wizard.tscn")
	var setup_wizard_instance : Node = setup_wizard_scene.instantiate()
	add_child(setup_wizard_instance)

func _show_plugin_dialogues() -> void:
	if not ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "disable_install_wizard", false):
		_open_confirmation_dialog()
		ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + "disable_install_wizard", true)
		ProjectSettings.save()
		return
	if is_partially_installed():
		_open_continue_setup_dialog()
		return

func _resave_if_recently_opened() -> void:
	if Engine.get_physics_frames() < MAX_PHYSICS_FRAMES_FROM_START:
		var timer: Timer = Timer.new()
		var callable := func():
			if Engine.get_frames_per_second() >= 10:
				timer.stop()
				EditorInterface.save_scene()
				timer.queue_free()
		timer.timeout.connect(callable)
		add_child(timer)
		timer.start(OPEN_EDITOR_DELAY)

func _add_audio_bus(bus_name : String) -> void:
	var has_bus_name := false
	for bus_idx in range(AudioServer.bus_count):
		var existing_bus_name := AudioServer.get_bus_name(bus_idx)
		if existing_bus_name == bus_name:
			has_bus_name = true
			break
	if not has_bus_name:
		AudioServer.add_bus()
		var new_bus_idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_idx, bus_name)
		AudioServer.set_bus_send(new_bus_idx, &"Master")
	ProjectSettings.save()

func _install_audio_busses() -> void:
	if not ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + "disable_install_audio_busses", false):
		_add_audio_bus("Music")
		_add_audio_bus("SFX")
		ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + "disable_install_audio_busses", true)
		ProjectSettings.save()

func _add_tool_options() -> void:
	add_tool_menu_item("Run " + get_plugin_name() + " Setup...", open_setup_wizard)

func _remove_tool_options() -> void:
	remove_tool_menu_item("Run " + get_plugin_name() + " Setup...")

func _add_to_auto_update_list() -> void:
	PluginUpdater.add_plugin(get_plugin_path(), PLUGIN_REPO_URL)

func _remove_from_auto_update_list() -> void:
	PluginUpdater.remove_plugin(get_plugin_path())

func _enable_plugin():
	_set_default_project_paths()
	add_autoload_singleton("SceneLoader", get_scene_loader_path())
	add_autoload_singleton("ProjectMusicController", get_plugin_path() + "base/nodes/autoloads/music_controller/project_music_controller.tscn")
	add_autoload_singleton("ProjectUISoundController", get_plugin_path() + "base/nodes/autoloads/ui_sound_controller/project_ui_sound_controller.tscn")

func _disable_plugin():
	remove_autoload_singleton("SceneLoader")
	remove_autoload_singleton("ProjectMusicController")
	remove_autoload_singleton("ProjectUISoundController")

func _enter_tree() -> void:
	_install_audio_busses()
	_add_tool_options()
	_add_translations()
	_show_plugin_dialogues()
	_add_to_auto_update_list()
	_resave_if_recently_opened()
	instance = self

func _exit_tree() -> void:
	_remove_tool_options()
	_remove_from_auto_update_list()
	instance = null
