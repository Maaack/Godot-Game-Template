@tool
extends Node
## Script for comparing the version of a plugin to the latest release.

signal new_version_detected(new_version:String)
signal versions_matched(current_version:String)
signal failed
signal done

const APIClient = PluginUpdater.APIClient

const GITHUB_REGEX := "https:\\/\\/github\\.com\\/([\\w-]+)\\/([\\w-]+)\\/*"
const GITHUB_RELEASES_URL := "https://api.github.com/repos/%s/%s/releases"
const RELEASES_URL_MAP := {
	GITHUB_REGEX : GITHUB_RELEASES_URL
}

## The directory of the plugin to update. Typically in res://addons/.
@export var plugin_directory : String
## The URL of the GitHub repo to pull new releases.
@export var plugin_repo_url : String : set = set_plugin_repo_url
@export_group("Advanced")
## The default lowest version to display.
@export var default_version : String = "0.0.0"
## Test comparing versions.
@export_tool_button("Compare Versions", "ToolConnect") var _compare_versions_action = compare_versions_verbose

@onready var _api_client : APIClient = $APIClient

var _zipball_url : String
var plugin_version : String = default_version : get = get_plugin_version
var plugin_name : String : get = get_plugin_name

func load_plugin_data() -> bool:
	if plugin_directory.is_empty():
		return true
	for enabled_plugin in PluginUpdater.get_enabled_plugins():
		if enabled_plugin.contains(plugin_directory):
			var config := ConfigFile.new()
			var error = config.load(enabled_plugin)
			if error != OK:
				return false
			plugin_version = config.get_value("plugin", "version", default_version)
			plugin_name = config.get_value("plugin", "name", "Unknown")
			return true
	return false

func get_plugin_version() -> String:
	if plugin_version.is_empty() or plugin_version == default_version:
		load_plugin_data()
	return plugin_version

func get_plugin_name() -> String:
	if plugin_name.is_empty():
		load_plugin_data()
	return plugin_name

func set_plugin_repo_url(value:String) -> void:
	plugin_repo_url = value
	if is_inside_tree():
		_update_api_url()

func _update_api_url() -> void:
	if plugin_repo_url.is_empty(): return
	if _api_client == null: return
	for regex_key in RELEASES_URL_MAP:
		var regex := RegEx.create_from_string(regex_key)
		var regex_match := regex.search(plugin_repo_url)
		if regex_match == null:
			continue
		var username := regex_match.get_string(1)
		var repository := regex_match.get_string(2)
		_api_client.api_url = RELEASES_URL_MAP[regex_key] % [username, repository]
		return

func _on_api_client_request_failed(error) -> void:
	failed.emit()
	done.emit()

func _on_api_client_response_received(response_body) -> void:
	if response_body is not Array or response_body.is_empty():
		failed.emit()
		return
	var latest_release : Dictionary = response_body.front()
	var tag_name := default_version
	if latest_release.has("tag_name"):
		tag_name = latest_release["tag_name"]
	if not load_plugin_data():
		return
	var current_tag_name = get_plugin_version()
	if tag_name == current_tag_name:
		versions_matched.emit(tag_name)
	else:
		var regex := RegEx.create_from_string("^[^0-9]*(.+)$")
		var regex_match := regex.search(tag_name)
		if regex_match.get_group_count() > 0 and regex_match.get_string(1) == current_tag_name:
			versions_matched.emit(tag_name)
		else:
			new_version_detected.emit(tag_name)
	done.emit()

func compare_versions(_plugin_directory = plugin_directory, _plugin_repo_url = plugin_repo_url) -> void:
	_update_api_url()
	_api_client.request()

func _on_failed_verbose():
	print("%s %s ?? (check failed!)" % [get_plugin_name(), get_plugin_version()])

func _on_versions_matched(version: String):
	print("%s %s == %s" % [get_plugin_name(), get_plugin_version(), version])

func _on_new_version_detected(version: String):
	print("%s %s != %s (new version!)" % [get_plugin_name(), get_plugin_version(), version])

func compare_versions_verbose() -> void:
	failed.connect(_on_failed_verbose)
	versions_matched.connect(_on_versions_matched)
	new_version_detected.connect(_on_new_version_detected)
	compare_versions(plugin_directory, plugin_repo_url)
	await done
	failed.disconnect(_on_failed_verbose)
	versions_matched.disconnect(_on_versions_matched)
	new_version_detected.disconnect(_on_new_version_detected)

func set_plugin(_plugin_directory, _plugin_repo_url):
	plugin_directory = _plugin_directory
	plugin_repo_url = _plugin_repo_url
	_update_api_url()
