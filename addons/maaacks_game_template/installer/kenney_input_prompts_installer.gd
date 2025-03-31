@tool
class_name InputIconsInstaller
extends Node

signal canceled
signal completed

@export_dir var asset_dir_path : String
@export var extract_extension : String

var _configuration_index : int = 0
var installation_stage : int = 0

func _on_kenney_input_prompts_dialog_canceled():
	canceled.emit()
	queue_free()

func _on_kenney_input_prompts_dialog_configuration_selected(index: int):
	_configuration_index = index

func _on_kenney_input_prompts_dialog_confirmed():
	var full_path = asset_dir_path
	if not full_path.ends_with("/"):
		full_path += "/"
	full_path += extract_extension
	$InstallingDialog.show()
	$DownloadAndUnzip.extract_path = full_path
	$DownloadAndUnzip.request.call_deferred()

func _process(_delta):
	if $InstallingDialog.visible:
		%ProgressBar.value = $DownloadAndUnzip.get_progress()
		match $DownloadAndUnzip.stage:
			DownloadAndUnzip.Stage.DOWNLOAD:
				%StageLabel.text = "Downloading..."
			DownloadAndUnzip.Stage.EXTRACT:
				%StageLabel.text = "Extracting..."
			DownloadAndUnzip.Stage.DELETE:
				%StageLabel.text = "Cleaning up..."
			DownloadAndUnzip.Stage.NONE:
				$InstallingDialog.hide()
				completed.emit()
				queue_free()
