@tool
extends Node

const API_RELEASES_URL := "https://api.github.com/repos/%s/%s/releases"
const UPDATE_CONFIRMATION_MESSAGE := "This will update the contents of the plugin folder (addons/%s/).\nFiles outside of the plugin folder will not be affected.\n\nUpdate to v%s?"
const PLUGIN_EXTRACT_PATH := "res://addons/%s"
const PLUGIN_TEMP_ZIP_PATH := "res://%s_%s_update.zip"

@export var plugin_directory : String :
	set(value):
		plugin_directory = value
		_update_paths()
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
			get_newest_version()

@onready var _api_client : APIClient = $APIClient
@onready var _download_and_extract_node : DownloadAndExtract = $DownloadAndExtract
@onready var _update_confirmation_dialog : ConfirmationDialog = $UpdateConfirmationDialog
@onready var _error_dialog : AcceptDialog = $ErrorDialog

var _zipball_url : String
var _newest_version : String

func get_plugin_version():
	if plugin_directory.is_empty(): return
	for enabled_plugin in ProjectSettings.get_setting("editor_plugins/enabled"):
		if enabled_plugin.contains(plugin_directory):
			var config := ConfigFile.new()
			var error = config.load(enabled_plugin)
			if error != OK:
				return
			return config.get_value("plugin", "version", default_version)

func _update_paths():
	if plugin_directory.is_empty(): return
	if _download_and_extract_node == null: return
	_download_and_extract_node.extract_path = PLUGIN_EXTRACT_PATH % plugin_directory

func _update_urls():
	if plugin_github_url.is_empty(): return
	if _api_client == null: return
	var regex := RegEx.create_from_string("https:\\/\\/github\\.com\\/([\\w-]+)\\/([\\w-]+)\\/*")
	var regex_match := regex.search(plugin_github_url)
	if regex_match == null: return
	var username := regex_match.get_string(1)
	var repository := regex_match.get_string(2)
	_api_client.api_url = API_RELEASES_URL % [username, repository]

func _show_error_dialog(error):
	_error_dialog.show()
	_error_dialog.dialog_text = "%s!" % error

func _on_api_client_request_failed(error):
	_show_error_dialog(error)

func _on_api_client_response_received(response_body):
	if response_body is not Array:
		push_error("Response was not an array")
		return
	var latest_release : Dictionary = response_body.front()
	_newest_version = default_version
	if latest_release.has("tag_name"):
		var tag_name = latest_release["tag_name"]
		if replace_tag_name:
			tag_name = tag_name.replacen(replace_tag_name, "")
		_newest_version = tag_name
	if latest_release.has("zipball_url"):
		_zipball_url = latest_release["zipball_url"]
	var current_tag_name = get_plugin_version()
	_download_and_extract_node.zip_url = _zipball_url
	_download_and_extract_node.zip_file_path = PLUGIN_TEMP_ZIP_PATH % [plugin_directory, _newest_version]
	_update_confirmation_dialog.dialog_text = UPDATE_CONFIRMATION_MESSAGE % [plugin_directory, _newest_version]
	_update_confirmation_dialog.show()

func _on_error_dialog_canceled():
	queue_free()

func _on_error_dialog_confirmed():
	queue_free()

func _on_update_confirmation_dialog_canceled():
	queue_free()

func _on_update_confirmation_dialog_confirmed():
	print("download %s" % _zipball_url)

func get_newest_version():
	_api_client.request()

func _ready():
	_update_confirmation_dialog.hide()
	if auto_start:
		get_newest_version()
