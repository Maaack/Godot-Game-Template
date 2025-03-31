@tool
class_name InputIconsInstaller
extends Node

signal canceled
signal completed

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

@export_dir var copy_dir_path : String
@export var extract_extension : String

var _configuration_index : int = -1
var installation_stage : int = 0

func _on_kenney_input_prompts_dialog_canceled():
	canceled.emit()
	queue_free()

func _on_kenney_input_prompts_dialog_configuration_selected(index: int):
	_configuration_index = index

func _on_kenney_input_prompts_dialog_confirmed():
	var full_path = copy_dir_path
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

func _configure_icons():
	var input_options_menu_path := copy_dir_path + "scenes/menus/options_menu/input/input_options_menu.tscn"
	var input_options_menu := FileAccess.get_file_as_string(input_options_menu_path)
	var regex := RegEx.new()
	regex.compile(REGEX_PREFIX + """\\[node""")
	var result = regex.sub(input_options_menu, "[node")
	if result == input_options_menu:
		print("the same")
		regex.clear()
		regex.compile(REGEX_PREFIX)
		result = regex.sub(input_options_menu, "")
		if result == input_options_menu:
			print("still the same")
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
	EditorInterface.save_scene()

func _on_download_and_unzip_request_completed():
	_configure_icons()
	completed.emit()
	queue_free()
