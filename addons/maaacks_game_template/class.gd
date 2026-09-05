@tool
class_name MaaacksGameTemplate
extends RefCounted

const PLUGIN_NAME = "Maaack's Game Template"
const PROJECT_SETTINGS_PATH = "maaacks_game_template/"
const MAIN_SCENE_RELATIVE_PATH = "scenes/opening/opening.tscn"
const MAIN_MENU_RELATIVE_PATH = "scenes/menus/main_menu/main_menu.tscn"
const GAME_SCENE_RELATIVE_PATH = "scenes/game/game.tscn"
const ENDING_SCENE_RELATIVE_PATH = "scenes/end_credits/end_credits.tscn"
const COPY_PATH_KEY = "copy_path"
const MAIN_MENU_SCENE_PATH_KEY = "main_menu_scene_path"
const GAME_SCENE_PATH_KEY = "game_scene_path"
const ENDING_SCENE_PATH_KEY = "ending_scene_path"
const SCENE_PATHS : Dictionary[String, String] = {
	MAIN_MENU_SCENE_PATH_KEY : MAIN_MENU_RELATIVE_PATH,
	GAME_SCENE_PATH_KEY : GAME_SCENE_RELATIVE_PATH,
	ENDING_SCENE_PATH_KEY : ENDING_SCENE_RELATIVE_PATH,
}

static func get_plugin_name() -> String:
	return PLUGIN_NAME

static func get_settings_path() -> String:
	return PROJECT_SETTINGS_PATH

static func get_main_scene_relative_path() -> String:
	return MAIN_SCENE_RELATIVE_PATH

static func get_copy_path(default_path : String = "") -> String:
	var copy_path = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + COPY_PATH_KEY, default_path)
	if not copy_path.ends_with("/"):
		copy_path += "/"
	return copy_path

static func set_copy_path(copy_path : String) -> void:
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + COPY_PATH_KEY, copy_path)
	ProjectSettings.save()

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

static func set_project_paths(target_path : String, overwrite : bool = true) -> void:
	for key in SCENE_PATHS:
		var relative_path = SCENE_PATHS[key]
		var stored_path := ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + key)
		if (not overwrite) and stored_path != null:
			continue
		if relative_path.is_empty() and (not stored_path.is_empty()):
			continue
		var full_path = ""
		if not relative_path.is_empty():
			full_path = target_path + relative_path
		ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + key, full_path)
	ProjectSettings.save()

static func are_project_paths_updated(target_path) -> bool:
	for key in SCENE_PATHS:
		var relative_path = SCENE_PATHS[key]
		if relative_path.is_empty():
			continue
		var stored_path : String = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + key, "")
		if stored_path != target_path + relative_path:
			return false
	return true
