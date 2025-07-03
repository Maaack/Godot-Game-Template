@tool
extends Node

signal new_version_detected(version: String)
signal versions_matched
signal failed

const APIClient = MaaacksGameTemplatePlugin.APIClient

const API_RELEASES_URL := "https://api.github.com/repos/%s/%s/releases"

@export var plugin_directory : String
@export var plugin_github_url : String :
	set(value):
		plugin_github_url = value
		_update_urls()
@export_group("Advanced")
@export var auto_start : bool = false
@export var default_version : String = "0.0.0"
@export var replace_tag_name : String = "v"
@export var _test_action : bool = false :
	set(value):
		if value and Engine.is_editor_hint():
			compare_versions()

@onready var _api_client : APIClient = $APIClient

var _zipball_url : String

func get_plugin_version() -> String :
	if not plugin_directory.is_empty(): 
		for enabled_plugin in ProjectSettings.get_setting("editor_plugins/enabled"):
			if enabled_plugin.contains(plugin_directory):
				var config := ConfigFile.new()
				var error = config.load(enabled_plugin)
				if error != OK:
					return default_version
				return config.get_value("plugin", "version", default_version)
	return default_version

func _update_urls() -> void:
	if plugin_github_url.is_empty(): return
	if _api_client == null: return
	var regex := RegEx.create_from_string("https:\\/\\/github\\.com\\/([\\w-]+)\\/([\\w-]+)\\/*")
	var regex_match := regex.search(plugin_github_url)
	if regex_match == null: return
	var username := regex_match.get_string(1)
	var repository := regex_match.get_string(2)
	_api_client.api_url = API_RELEASES_URL % [username, repository]

func _on_api_client_request_failed(error) -> void:
	failed.emit()
	queue_free()

func _on_api_client_response_received(response_body) -> void:
	if response_body is not Array:
		failed.emit()
		queue_free()
		return
	var latest_release : Dictionary = response_body.front()
	var tag_name := default_version
	if latest_release.has("tag_name"):
		tag_name = latest_release["tag_name"]
	if replace_tag_name:
		tag_name = tag_name.replacen(replace_tag_name, "")
	var current_tag_name = get_plugin_version()
	if tag_name != current_tag_name:
		new_version_detected.emit(tag_name)
	else:
		versions_matched.emit()
	queue_free()

func compare_versions() -> void:
	_api_client.request()

func _ready() -> void:
	if auto_start:
		compare_versions()
