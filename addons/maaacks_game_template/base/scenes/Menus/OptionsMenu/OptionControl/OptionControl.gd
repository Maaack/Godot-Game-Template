@tool
class_name OptionControl
extends HBoxContainer

signal setting_changed(section : String, key : String, value)

enum OptionSections{
	NONE,
	INPUT,
	AUDIO,
	VIDEO,
}

const OptionSectionNames : Dictionary = {
	OptionSections.NONE : "",
	OptionSections.INPUT : AppSettings.INPUT_SECTION,
	OptionSections.AUDIO : AppSettings.AUDIO_SECTION,
	OptionSections.VIDEO : AppSettings.VIDEO_SECTION,
}

@export var option_section : OptionSections :
	set(value):
		var _update_config : bool = OptionSectionNames[option_section] == section
		option_section = value
		if _update_config:
			section = OptionSectionNames[option_section]
		
@export var option_name : String :
	set(value):
		var _update_config : bool = option_name.to_pascal_case() == key
		option_name = value
		if is_inside_tree():
			%OptionLabel.text = "%s%s" % [option_name, label_suffix]
		if _update_config:
			key = option_name.to_pascal_case()

@export_group("Config Names")
@export var section : String
@export var key : String

@export_group("Extras")
@export var label_suffix : String = " :"

func _on_setting_changed(value):
	Config.set_config(section, key, value)
	setting_changed.emit(section, key, value)

func _get_setting(default : Variant = null) -> Variant:
	return Config.get_config(section, key, default)

func _connect_option_inputs(node):
	if node is Button:
		if node is OptionButton:
			node.item_selected.connect(_on_setting_changed)
			node.select(_get_setting(false) as int)
		elif node is ColorPickerButton:
			node.color_changed.connect(_on_setting_changed)
			node.color = _get_setting(Color.WHITE) as Color
		else:
			node.toggled.connect(_on_setting_changed)
			node.button_pressed = _get_setting(false) as bool
	if node is Range:
		node.value_changed.connect(_on_setting_changed)
		node.value = _get_setting(0.0) as float
	if node is LineEdit:
		node.text_changed.connect(_on_setting_changed)
		node.text = "%s" % _get_setting("")
	if node is TextEdit:
		node.text_changed.connect(_on_setting_changed)
		node.text = "%s" % _get_setting("")

func _ready():
	option_section = option_section
	option_name = option_name
	child_entered_tree.connect(_connect_option_inputs)
	for child in get_children():
		_connect_option_inputs(child)
