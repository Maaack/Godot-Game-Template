@tool
class_name MaaacksSceneLoader
extends RefCounted

const PLUGIN_NAME = "Maaack's Scene Loader"
const PROJECT_SETTINGS_PATH = "maaacks_scene_loader/"
const LOADING_SCREEN_SCENE_RELATIVE_PATH = "base/nodes/loading_screen/loading_screen.tscn"
const LOADING_SCENE_PATH_KEY = "loading_scene_path"
const SCENE_PATHS : Dictionary[String, String] = {
	LOADING_SCENE_PATH_KEY : LOADING_SCREEN_SCENE_RELATIVE_PATH,
}
static func get_plugin_name() -> String:
	return PLUGIN_NAME

static func get_settings_path() -> String:
	return PROJECT_SETTINGS_PATH

static func get_loading_scene_path(override_path : String = "") -> String:
	if (not override_path.is_empty()) and FileAccess.file_exists(override_path):
		return override_path
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + LOADING_SCENE_PATH_KEY, override_path)

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
