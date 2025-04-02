@tool
## Tool for installing icons and setting up the configuration of the input icon mapper.
extends Node

## Sent when the user selects to cancel the installation process.
signal canceled
## Sent when the installation process has completed.
signal completed

const REIMPORT_CHECK_DELAY : float = 0.5
const OPEN_SCENE_DELAY : float = 0.5
const REGEX_PREFIX = """\\[node name="InputIconMapper" parent="." index="0"\\][\\s\\S]*"""

const FILLED_WHITE_CONFIGURATION = """
[node name="InputIconMapper" parent="." index="0"]
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
[node name="InputIconMapper" parent="." index="0"]
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
[node name="InputIconMapper" parent="." index="0"]
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
[node name="InputIconMapper" parent="." index="0"]
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

## Path start where the project examples have been copied.
@export_dir var copy_dir_path : String
## Path end where the zipped files are to be extracted.
@export var extract_extension : String

var _configuration_index : int = -1
## State flag of whether the tool is waiting for the filesystem to finish scanning.
var scanning : bool = false
## State flag for whether the tool is waiting for the filesystem to finish reimporting.
var reimporting : bool = false
## Flag for whether the tool will force a download and extraction, even if the contents exist.
var force : bool = false

func _on_kenney_input_prompts_dialog_canceled():
	canceled.emit()
	queue_free()

func _on_kenney_input_prompts_dialog_configuration_selected(index: int):
	_configuration_index = index

func _download_and_extract():
	$InstallingDialog.show()
	$DownloadAndExtract.run.call_deferred()

func _on_kenney_input_prompts_dialog_confirmed():
	if $DownloadAndExtract.extract_path_exists() and not force:
		_configure_icons()
		completed.emit()
		queue_free()
		return
	_download_and_extract()

func _process(_delta):
	if $InstallingDialog.visible:
		%ProgressBar.value = $DownloadAndExtract.get_progress()
		match $DownloadAndExtract.stage:
			DownloadAndExtract.Stage.DOWNLOAD:
				%StageLabel.text = "Downloading..."
			DownloadAndExtract.Stage.EXTRACT:
				%StageLabel.text = "Extracting..."
			DownloadAndExtract.Stage.DELETE:
				%StageLabel.text = "Cleaning up..."
			DownloadAndExtract.Stage.NONE:
				$InstallingDialog.hide()
	elif scanning:
		var file_system := EditorInterface.get_resource_filesystem()
		if not file_system.is_scanning():
			scanning = false
			await get_tree().create_timer(REIMPORT_CHECK_DELAY).timeout
			if reimporting:
				await file_system.resources_reimported
			reimporting = false
			_configure_icons()
			completed.emit()
			queue_free()

func _configure_icons():
	var input_options_menu_path := copy_dir_path + "scenes/menus/options_menu/input/input_options_menu.tscn"
	var input_options_menu := FileAccess.get_file_as_string(input_options_menu_path)
	var regex := RegEx.new()
	regex.compile(REGEX_PREFIX + """\\[node""")
	var result = regex.sub(input_options_menu, "[node")
	if result == input_options_menu:
		regex.clear()
		regex.compile(REGEX_PREFIX)
		result = regex.sub(input_options_menu, "")
	input_options_menu = result
	match(_configuration_index):
		0:
			input_options_menu += FILLED_COLOR_CONFIGURATION
		1:
			input_options_menu += FILLED_WHITE_CONFIGURATION
		2:
			input_options_menu += OUTLINED_COLOR_CONFIGURATION
		3:
			input_options_menu += OUTLINED_WHITE_CONFIGURATION
	var file_rewrite := FileAccess.open(input_options_menu_path, FileAccess.WRITE)
	file_rewrite.store_string(input_options_menu)
	file_rewrite.close()
	if input_options_menu_path in EditorInterface.get_open_scenes():
		EditorInterface.reload_scene_from_path(input_options_menu_path)
	else:
		EditorInterface.open_scene_from_path(input_options_menu_path)
	await get_tree().create_timer(OPEN_SCENE_DELAY).timeout
	EditorInterface.save_scene()

func _scan_filesystem_and_reimport():
	var file_system := EditorInterface.get_resource_filesystem()
	file_system.scan()
	scanning = true
	await file_system.resources_reimporting
	reimporting = true

func _ready():
	$ForceConfirmationDialog.hide()
	$KenneyInputPromptsDialog.hide()
	$InstallingDialog.hide()
	$InstallingDialog.get_ok_button().hide()
	$ErrorDialog.hide()
	var full_path = copy_dir_path
	if not full_path.ends_with("/"):
		full_path += "/"
	full_path += extract_extension
	$DownloadAndExtract.extract_path = full_path
	if $DownloadAndExtract.extract_path_exists():
		$ForceConfirmationDialog.show()
	else:
		$KenneyInputPromptsDialog.show()

func _on_force_confirmation_dialog_canceled():
	force = true
	$DownloadAndExtract.force = true
	$KenneyInputPromptsDialog.show.call_deferred()

func _on_force_confirmation_dialog_confirmed():
	$KenneyInputPromptsDialog.set_short_description()
	$KenneyInputPromptsDialog.show.call_deferred()

func _show_error_dialog(error):
	$InstallingDialog.hide()
	$ErrorDialog.show()
	$ErrorDialog.dialog_text = "%s!" % error

func _on_error_dialog_confirmed():
	queue_free()

func _on_error_dialog_canceled():
	queue_free()

func _on_download_and_extract_run_completed():
	_scan_filesystem_and_reimport()

func _on_download_and_extract_run_failed(error):
	_show_error_dialog(error)
