@tool
class_name MaaacksSceneLoaderPlugin
extends EditorPlugin

const PLUGIN_REPO_URL = "https://github.com/Maaack/Godot-Scene-Loader"
const SCENE_LOADER_RELATIVE_PATH = "base/nodes/autoloads/scene_loader/scene_loader.tscn"

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func get_scene_loader_path() -> String:
	return get_plugin_path() + SCENE_LOADER_RELATIVE_PATH

func _add_to_auto_update_list() -> void:
	var plugin_repos:Dictionary = ProjectSettings.get_setting("plugin_updater/plugins", {})
	plugin_repos[get_plugin_path()] = PLUGIN_REPO_URL
	ProjectSettings.set_setting("plugin_updater/plugins", plugin_repos)

func _remove_from_auto_update_list() -> void:
	var plugin_repos:Dictionary = ProjectSettings.get_setting("plugin_updater/plugins", {})
	plugin_repos.erase(get_plugin_path())
	ProjectSettings.set_setting("plugin_updater/plugins", plugin_repos)

func _enable_plugin():
	MaaacksSceneLoader.set_project_paths(get_plugin_path())
	_add_to_auto_update_list()
	add_autoload_singleton("SceneLoader", get_scene_loader_path())

func _disable_plugin():
	_remove_from_auto_update_list()
	remove_autoload_singleton("SceneLoader")
