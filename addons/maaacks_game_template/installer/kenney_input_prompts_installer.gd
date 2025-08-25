@tool
## Tool for installing icons and setting up the configuration of the input icon mapper.
extends Node

## Sent when the user selects to cancel the installation process.
signal canceled
## Sent when the installation process has completed.
signal completed

const DownloadAndExtract = MaaacksGameTemplatePlugin.DownloadAndExtract
const RELATIVE_PATH_TO_CONFIGURE_SCENE = "scenes/menus/options_menu/input/input_icon_mapper.tscn"
const REIMPORT_CHECK_DELAY : float = 0.5
const OPEN_SCENE_DELAY : float = 0.5
const REGEX_PREFIX = """\\[node name="InputIconMapper" type="Node"\\][\\s\\S]*"""

const FILLED_WHITE_CONFIGURATION = """
replace_strings = {
"Capslock": "Caps Lock",
"Generic Stick": "Generic Left Stick",
"Guide": "Home",
"Slash Back": "Back Slash",
"Slash Forward": "Slash",
"Stick L": "Left Stick",
"Stick R": "Right Stick",
"Trigger L 1": "Left Shoulder",
"Trigger L 2": "Left Trigger",
"Trigger R 1": "Right Shoulder",
"Trigger R 2": "Right Trigger"
}
filtered_strings = Array[String](["keyboard", "color", "button", "arrow"])
directories = Array[String](["res://assets/kenney_input-prompts/Keyboard & Mouse/Default", "res://assets/kenney_input-prompts/Generic/Default", "res://assets/kenney_input-prompts/Xbox Series/Default", "res://assets/kenney_input-prompts/PlayStation Series/Default", "res://assets/kenney_input-prompts/Nintendo Switch/Default", "res://assets/kenney_input-prompts/Steam Deck/Default"])
filter = "color"
ends_with = ".png"
not_ends_with = "outline.png"
"""
const FILLED_COLOR_CONFIGURATION = """
prioritized_strings = Array[String](["color"])
replace_strings = {
"Capslock": "Caps Lock",
"Generic Stick": "Generic Left Stick",
"Guide": "Home",
"Slash Back": "Back Slash",
"Slash Forward": "Slash",
"Stick L": "Left Stick",
"Stick R": "Right Stick",
"Trigger L 1": "Left Shoulder",
"Trigger L 2": "Left Trigger",
"Trigger R 1": "Right Shoulder",
"Trigger R 2": "Right Trigger"
}
filtered_strings = Array[String](["keyboard", "color", "button", "arrow"])
directories = Array[String](["res://assets/kenney_input-prompts/Keyboard & Mouse/Default", "res://assets/kenney_input-prompts/Generic/Default", "res://assets/kenney_input-prompts/Xbox Series/Default", "res://assets/kenney_input-prompts/PlayStation Series/Default", "res://assets/kenney_input-prompts/Nintendo Switch/Default", "res://assets/kenney_input-prompts/Steam Deck/Default"])
ends_with = ".png"
not_ends_with = "outline.png"
"""
const OUTLINED_WHITE_CONFIGURATION = """
prioritized_strings = Array[String](["outline"])
replace_strings = {
"Capslock": "Caps Lock",
"Generic Stick": "Generic Left Stick",
"Guide": "Home",
"Slash Back": "Back Slash",
"Slash Forward": "Slash",
"Stick L": "Left Stick",
"Stick R": "Right Stick",
"Trigger L 1": "Left Shoulder",
"Trigger L 2": "Left Trigger",
"Trigger R 1": "Right Shoulder",
"Trigger R 2": "Right Trigger"
}
filtered_strings = Array[String](["keyboard", "color", "button", "arrow", "outline"])
directories = Array[String](["res://assets/kenney_input-prompts/Keyboard & Mouse/Default", "res://assets/kenney_input-prompts/Generic/Default", "res://assets/kenney_input-prompts/Xbox Series/Default", "res://assets/kenney_input-prompts/PlayStation Series/Default", "res://assets/kenney_input-prompts/Nintendo Switch/Default", "res://assets/kenney_input-prompts/Steam Deck/Default"])
filter = "color"
ends_with = ".png"
"""
const OUTLINED_COLOR_CONFIGURATION = """
prioritized_strings = Array[String](["outline", "color"])
replace_strings = {
"Capslock": "Caps Lock",
"Generic Stick": "Generic Left Stick",
"Guide": "Home",
"Slash Back": "Back Slash",
"Slash Forward": "Slash",
"Stick L": "Left Stick",
"Stick R": "Right Stick",
"Trigger L 1": "Left Shoulder",
"Trigger L 2": "Left Trigger",
"Trigger R 1": "Right Shoulder",
"Trigger R 2": "Right Trigger"
}
filtered_strings = Array[String](["keyboard", "color", "button", "arrow", "outline"])
directories = Array[String](["res://assets/kenney_input-prompts/Keyboard & Mouse/Default", "res://assets/kenney_input-prompts/Generic/Default", "res://assets/kenney_input-prompts/Xbox Series/Default", "res://assets/kenney_input-prompts/PlayStation Series/Default", "res://assets/kenney_input-prompts/Nintendo Switch/Default", "res://assets/kenney_input-prompts/Steam Deck/Default"])
ends_with = ".png"
"""

const PACKAGE_EXTRA_DIRECTORIES := [
	"Flairs",
	"Nintendo Gamecube",
	"Nintendo Switch 2",
	"Nintendo Wii",
	"Nintendo WiiU",
	"Playdate",
	"Steam Controller",
	"Touch",
]

const PACKAGE_EXTRA_FILES := [
	"Preview",
]

## Path start where the project examples have been copied.
@export_dir var copy_dir_path : String
## Path end where the zipped files are to be extracted.
@export var extract_extension : String

@onready var _download_and_extract_node : DownloadAndExtract = $DownloadAndExtract
@onready var _skip_installation_dialog : ConfirmationDialog = $SkipInstallationDialog
@onready var _kenney_input_prompts_dialog : ConfirmationDialog = $KenneyInputPromptsDialog
@onready var _installing_dialog : AcceptDialog = $InstallingDialog
@onready var _clean_up_dialog : ConfirmationDialog = $CleanUpDialog
@onready var _error_dialog : AcceptDialog = $ErrorDialog
@onready var _stage_label : Label = %StageLabel
@onready var _progress_bar : ProgressBar = %ProgressBar

var _configuration_index : int = -1
## State flag of whether the tool is waiting for the filesystem to finish scanning.
var scanning : bool = false
## State flag for whether the tool is waiting for the filesystem to finish reimporting.
var reimporting : bool = false
## Flag for whether the tool will force a download and extraction, even if the contents exist.
var force : bool = false

func _download_and_extract() -> void:
	_installing_dialog.show()
	_download_and_extract_node.run.call_deferred()

func _run_complete() -> void:
	completed.emit()
	queue_free()

func _clean_up_or_complete() -> void:
	if _has_extras():
		_clean_up_dialog.show()
	else:
		_run_complete()

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
	elif scanning:
		var file_system := EditorInterface.get_resource_filesystem()
		if not file_system.is_scanning():
			scanning = false
			await get_tree().create_timer(REIMPORT_CHECK_DELAY).timeout
			if reimporting:
				await file_system.resources_reimported
			reimporting = false
			_configure_and_complete()

func _delete_recursive(path : String) -> void:
	if not path.ends_with("/"):
		path += "/"
	var dir_access := DirAccess.open(path)
	if dir_access == null:
		return
	var directories := dir_access.get_directories()
	for directory in directories:
		_delete_recursive(path + directory)
		DirAccess.remove_absolute(path + directory)
	var files := dir_access.get_files()
	for file in files:
		DirAccess.remove_absolute(path + file)

func get_full_path() -> String:
	var full_path := copy_dir_path
	if not full_path.ends_with("/"):
		full_path += "/"
	full_path += extract_extension
	if not full_path.ends_with("/"):
		full_path += "/"
	return full_path

func _has_extras() -> bool:
	var full_path := get_full_path()
	var directories := DirAccess.get_directories_at(full_path)
	for directory in directories:
		for key in PACKAGE_EXTRA_DIRECTORIES:
			if directory.contains(key):
				return true
	var files := DirAccess.get_files_at(full_path)
	for file in files:
		for key in PACKAGE_EXTRA_FILES:
			if file.contains(key):
				return true
	return false

func _delete_extras() -> void:
	var full_path := get_full_path()
	var directories := DirAccess.get_directories_at(full_path)
	for directory in directories:
		for key in PACKAGE_EXTRA_DIRECTORIES:
			if directory.contains(key):
				_delete_recursive(full_path + directory)
				DirAccess.remove_absolute(full_path + directory)
				continue
	var files := DirAccess.get_files_at(full_path)
	for file in files:
		for key in PACKAGE_EXTRA_FILES:
			if file.contains(key):
				DirAccess.remove_absolute(full_path + file)
				continue
	EditorInterface.get_resource_filesystem().scan()

func _configure_icons() -> void:
	var input_options_menu_path := copy_dir_path + RELATIVE_PATH_TO_CONFIGURE_SCENE
	var input_options_menu := FileAccess.get_file_as_string(input_options_menu_path)
	match(_configuration_index % 4):
		0:
			input_options_menu += FILLED_COLOR_CONFIGURATION
		1:
			input_options_menu += FILLED_WHITE_CONFIGURATION
		2:
			input_options_menu += OUTLINED_COLOR_CONFIGURATION
		3:
			input_options_menu += OUTLINED_WHITE_CONFIGURATION
	match(_configuration_index / 4):
		0:
			input_options_menu = input_options_menu.replace("Default", "Vector").replace(".png", ".svg")
		1:
			pass
		2:
			input_options_menu = input_options_menu.replace("Default", "Double")
	var file_rewrite := FileAccess.open(input_options_menu_path, FileAccess.WRITE)
	file_rewrite.store_string(input_options_menu)
	file_rewrite.close()
	if input_options_menu_path in EditorInterface.get_open_scenes():
		EditorInterface.reload_scene_from_path(input_options_menu_path)
	else:
		EditorInterface.open_scene_from_path(input_options_menu_path)
	await get_tree().create_timer(OPEN_SCENE_DELAY).timeout
	EditorInterface.save_scene()
	await get_tree().create_timer(REIMPORT_CHECK_DELAY).timeout
	_clean_up_or_complete()

func _configure_and_complete() -> void:
	if _configuration_index >= 0: 
		_configure_icons()
		return
	_clean_up_or_complete()

func _scan_filesystem_and_reimport() -> void:
	var file_system := EditorInterface.get_resource_filesystem()
	file_system.scan()
	scanning = true
	await file_system.resources_reimporting
	reimporting = true

func _enable_forced_install() -> void:
	force = true
	_download_and_extract_node.force = true
	_kenney_input_prompts_dialog.show.call_deferred()

func _enable_skipped_install() -> void:
	_kenney_input_prompts_dialog.set_short_description()
	_kenney_input_prompts_dialog.show.call_deferred()

func _show_error_dialog(error : String) -> void:
	_installing_dialog.hide()
	_error_dialog.show()
	_error_dialog.dialog_text = "%s!" % error

func _ready() -> void:
	_skip_installation_dialog.hide()
	_kenney_input_prompts_dialog.hide()
	_installing_dialog.hide()
	_installing_dialog.get_ok_button().hide()
	_clean_up_dialog.hide()
	_error_dialog.hide()
	_download_and_extract_node.extract_path = get_full_path()
	if _download_and_extract_node.extract_path_exists():
		_skip_installation_dialog.show()
	else:
		_kenney_input_prompts_dialog.show()

func _on_kenney_input_prompts_dialog_canceled() -> void:
	canceled.emit()
	queue_free()

func _on_kenney_input_prompts_dialog_configuration_selected(index: int) -> void:
	_configuration_index = index

func _on_kenney_input_prompts_dialog_confirmed() -> void:
	if _download_and_extract_node.extract_path_exists() and not force:
		_configure_and_complete()
		return
	_download_and_extract()

func _on_skip_installation_dialog_canceled() -> void:
	_enable_forced_install()

func _on_skip_installation_dialog_confirmed() -> void:
	_enable_skipped_install()

func _on_error_dialog_confirmed() -> void:
	queue_free()

func _on_error_dialog_canceled() -> void:
	queue_free()

func _on_download_and_extract_run_completed() -> void:
	_scan_filesystem_and_reimport()

func _on_download_and_extract_run_failed(error : String) -> void:
	_show_error_dialog(error)

func _on_clean_up_dialog_confirmed() -> void:
	_delete_extras()
	_run_complete()

func _on_clean_up_dialog_canceled() -> void:
	_run_complete()
