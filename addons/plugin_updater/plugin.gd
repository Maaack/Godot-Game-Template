@tool
class_name PluginUpdater
extends EditorPlugin

const PROJECT_SETTINGS_PATH := "plugin_updater/plugins"
const PROJECT_REPO_URL := "https://github.com/Maaack/Godot-Plugin-Updater"
const APIClient := preload("utilities/api_client.gd")
const DownloadAndExtract := preload("utilities/download_and_extract.gd")
const CheckPluginVersion := preload("updater/check_plugin_version.gd")
const UpdatePlugin := preload("updater/update_plugin.gd")

static var instance:PluginUpdater
var _check_plugin_version_scene:PackedScene = preload("updater/check_plugin_version.tscn")
var _update_plugin_scene:PackedScene = preload("updater/update_plugin.tscn")
var added_menu_item:bool = false
var submenu_directory_id_map:Dictionary[String, int]
var submenu_id_directory_map:Dictionary[int, String]
var popup_menu:PopupMenu

static func get_plugin_repos() -> Dictionary:
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH, {})

static func add_plugin(plugin_directory:String, plugin_repo_url:String):
	var plugin_repos := get_plugin_repos()
	plugin_repos[plugin_directory] = plugin_repo_url
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH, plugin_repos)
	ProjectSettings.save()

static func remove_plugin(plugin_directory:String):
	var plugin_repos := get_plugin_repos()
	plugin_repos.erase(plugin_directory)
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH, plugin_repos)
	ProjectSettings.save()

static func get_enabled_plugins() -> PackedStringArray:
	return ProjectSettings.get_setting("editor_plugins/enabled", [] as PackedStringArray)

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func _on_new_version_detected(new_plugin_version:String, check_version_instance:CheckPluginVersion) -> void:
	_add_update_plugin_tool_option(check_version_instance.get_plugin_name(), new_plugin_version, check_version_instance.plugin_directory, check_version_instance.plugin_repo_url)

func get_check_plugin_version(plugin_directory:String, plugin_repo_url:String) -> CheckPluginVersion:
	var check_version_instance:CheckPluginVersion = _check_plugin_version_scene.instantiate()
	check_version_instance.plugin_directory = plugin_directory
	check_version_instance.plugin_repo_url = plugin_repo_url
	return check_version_instance

func _check_all_registered_plugins() -> void:
	var plugin_repos = get_plugin_repos()
	if plugin_repos.is_empty():
		return
	var check_version_instance:CheckPluginVersion = _check_plugin_version_scene.instantiate()
	add_child.call_deferred(check_version_instance)
	await check_version_instance.ready
	check_version_instance.new_version_detected.connect(_on_new_version_detected.bind(check_version_instance))
	for plugin_directory in plugin_repos:
		check_version_instance.plugin_directory = plugin_directory
		check_version_instance.plugin_repo_url = plugin_repos[plugin_directory]
		check_version_instance.compare_versions()
		await check_version_instance.done
	check_version_instance.queue_free()

func open_update_plugin(plugin_directory:String, plugin_repo_url:String) -> void:
	var update_plugin_instance:UpdatePlugin = _update_plugin_scene.instantiate()
	add_child.call_deferred(update_plugin_instance)
	await update_plugin_instance.ready
	update_plugin_instance.update_completed.connect(_remove_update_plugin_submenu_option.bind(plugin_directory))
	update_plugin_instance.plugin_directory = plugin_directory
	update_plugin_instance.plugin_repo_url = plugin_repo_url
	update_plugin_instance.get_latest_release()

func get_popup_menu() -> PopupMenu:
	if not popup_menu:
		popup_menu = PopupMenu.new()
	return popup_menu

func _on_id_pressed(id:int):
	var plugin_directory := submenu_id_directory_map[id]
	var plugin_directories := get_plugin_repos()
	var plugin_repo_url:String = plugin_directories[plugin_directory]
	open_update_plugin(plugin_directory, plugin_repo_url)

func _add_update_plugin_tool_option(plugin_name:String, new_version:String, plugin_directory:String, plugin_repo_url:String) -> void:
	var _popup_menu := get_popup_menu()
	var _submenu_item_id = submenu_directory_id_map.size()
	_popup_menu.add_item("%s to %s" % [plugin_name, new_version], _submenu_item_id)
	submenu_directory_id_map[plugin_directory] = _submenu_item_id
	submenu_id_directory_map[_submenu_item_id] = plugin_directory
	if not _popup_menu.id_pressed.is_connected(_on_id_pressed):
		_popup_menu.id_pressed.connect(_on_id_pressed)
	if not added_menu_item:
		add_tool_submenu_item("Update Plugins...", _popup_menu)
		added_menu_item = true

func _remove_update_plugin_submenu_option(plugin_directory:String) -> void:
	if not plugin_directory in submenu_directory_id_map:
		return
	var _submenu_item_id = submenu_directory_id_map[plugin_directory]
	var _popup_menu := get_popup_menu()
	var _index := _popup_menu.get_item_index(_submenu_item_id)
	_popup_menu.remove_item(_index)
	submenu_directory_id_map.erase(plugin_directory)
	submenu_id_directory_map.erase(_submenu_item_id)
	if submenu_directory_id_map.is_empty():
		_remove_update_plugin_tool_option()

func _remove_update_plugin_tool_option() -> void:
	if not added_menu_item:
		return
	remove_tool_menu_item("Update Plugins...")

func _add_tool_options() -> void:
	_check_all_registered_plugins()

func _remove_tool_options() -> void:
	_remove_update_plugin_tool_option()

func _enable_plugin():
	add_plugin(get_plugin_path(), PROJECT_REPO_URL)

func _disable_plugin():
	remove_plugin(get_plugin_path())

func _enter_tree() -> void:
	_add_tool_options()
	instance = self

func _exit_tree() -> void:
	_remove_tool_options()
	instance = null
