@tool
extends Node

signal update_completed

const DownloadAndExtract = MaaacksGameTemplatePlugin.DownloadAndExtract
const APIClient = MaaacksGameTemplatePlugin.APIClient
const ReleaseNotesLabel = preload("./release_notes_label.gd")

const API_RELEASES_URL := "https://api.github.com/repos/%s/%s/releases"
const UPDATE_CONFIRMATION_MESSAGE := "This will update the contents of the plugin folder (addons/%s/).\nFiles outside of the plugin folder will not be affected.\n\nUpdate %s to v%s?"
const PLUGIN_EXTRACT_PATH := "res://addons/%s/"
const PLUGIN_TEMP_ZIP_PATH := "res://%s_%s_update.zip"

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
			get_newest_version()

@onready var _api_client : APIClient = $APIClient
@onready var _download_and_extract_node : DownloadAndExtract = $DownloadAndExtract
@onready var _update_confirmation_dialog : ConfirmationDialog = $UpdateConfirmationDialog
@onready var _installing_dialog : AcceptDialog = $InstallingDialog
@onready var _error_dialog : AcceptDialog = $ErrorDialog
@onready var _success_dialog : AcceptDialog = $SuccessDialog
@onready var _release_notes_label : ReleaseNotesLabel = %ReleaseNotesLabel
@onready var _update_label : Label = %UpdateLabel
@onready var _warning_message_button : LinkButton = %WarningMessageButton
@onready var _warning_message_label : Label = %WarningMessageLabel
@onready var _release_notes_button : LinkButton = %ReleaseNotesButton
@onready var _release_notes_panel : Panel = %ReleaseNotesPanel
@onready var _stage_label : Label = %StageLabel
@onready var _progress_bar : ProgressBar = %ProgressBar

var _zipball_url : String
var _newest_version : String
var _plugin_name : String
var _current_plugin_version : String

func _load_plugin_details() -> void:
	if plugin_directory.is_empty(): return
	for enabled_plugin in ProjectSettings.get_setting("editor_plugins/enabled"):
		if enabled_plugin.contains(plugin_directory):
			var config := ConfigFile.new()
			var error = config.load(enabled_plugin)
			if error != OK:
				return
			_current_plugin_version = config.get_value("plugin", "version", default_version)
			_plugin_name = config.get_value("plugin", "name", "Plugin")

func _update_urls() -> void:
	if plugin_github_url.is_empty(): return
	if _api_client == null: return
	var regex := RegEx.create_from_string("https:\\/\\/github\\.com\\/([\\w-]+)\\/([\\w-]+)\\/*")
	var regex_match := regex.search(plugin_github_url)
	if regex_match == null: return
	var username := regex_match.get_string(1)
	var repository := regex_match.get_string(2)
	_api_client.api_url = API_RELEASES_URL % [username, repository]

func _show_error_dialog(error : String) -> void:
	_error_dialog.show()
	_error_dialog.dialog_text = "%s!" % error

func _show_success_dialog() -> void:
	_success_dialog.show()
	_success_dialog.dialog_text = "%s updated to v%s." % [_plugin_name, _newest_version]

func _on_api_client_request_failed(error : String) -> void:
	_show_error_dialog(error)

func _on_api_client_response_received(response_body : Variant) -> void:
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
	_download_and_extract_node.zip_url = _zipball_url
	_download_and_extract_node.zip_file_path = PLUGIN_TEMP_ZIP_PATH % [plugin_directory, _newest_version]
	_update_label.text = UPDATE_CONFIRMATION_MESSAGE % [plugin_directory, _plugin_name, _newest_version]
	if latest_release.has("body"):
		_release_notes_label.from_release_notes(latest_release["body"])
	_update_confirmation_dialog.show()

func _on_download_and_extract_zip_saved() -> void:
	OS.move_to_trash(ProjectSettings.globalize_path(PLUGIN_EXTRACT_PATH % plugin_directory))

func _on_download_and_extract_run_failed(error : String) -> void:
	_show_error_dialog(error)

func _on_download_and_extract_run_completed() -> void:
	update_completed.emit()
	_show_success_dialog()

func _on_error_dialog_canceled() -> void:
	queue_free()

func _on_error_dialog_confirmed() -> void:
	queue_free()

func _on_success_dialog_canceled() -> void:
	queue_free()

func _on_success_dialog_confirmed() -> void:
	queue_free()

func _on_update_confirmation_dialog_canceled() -> void:
	queue_free()

func _on_update_confirmation_dialog_confirmed() -> void:
	_download_and_extract_node.run()
	_installing_dialog.show()

func _on_warning_message_button_pressed():
	_warning_message_label.show()
	_warning_message_button.hide()

func _on_release_notes_button_pressed() -> void:
	_release_notes_panel.show()
	_release_notes_button.hide()

func get_newest_version() -> void:
	_api_client.request()

func _ready() -> void:
	_load_plugin_details()
	_update_confirmation_dialog.hide()
	_installing_dialog.hide()
	_error_dialog.hide()
	_success_dialog.hide()
	if auto_start:
		get_newest_version()

func _process(_delta : float) -> void:
	if _installing_dialog.visible:
		_progress_bar.value = _download_and_extract_node.get_progress()
		match _download_and_extract_node.stage:
			DownloadAndExtract.DownloadAndExtractStage.DOWNLOAD:
				_stage_label.text = "Downloading..."
			DownloadAndExtract.DownloadAndExtractStage.SAVE:
				_stage_label.text = "Saving..."
			DownloadAndExtract.DownloadAndExtractStage.EXTRACT:
				_stage_label.text = "Extracting..."
			DownloadAndExtract.DownloadAndExtractStage.DELETE:
				_stage_label.text = "Cleaning up..."
			DownloadAndExtract.DownloadAndExtractStage.NONE:
				_installing_dialog.hide()
