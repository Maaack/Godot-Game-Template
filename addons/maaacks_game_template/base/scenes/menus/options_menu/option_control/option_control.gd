@tool
class_name OptionControl
extends Control

signal setting_changed(value)

enum OptionSections{
	NONE,
	INPUT,
	AUDIO,
	VIDEO,
	GAME,
	APPLICATION,
	CUSTOM,
}

const OptionSectionNames : Dictionary = {
	OptionSections.NONE : "",
	OptionSections.INPUT : AppSettings.INPUT_SECTION,
	OptionSections.AUDIO : AppSettings.AUDIO_SECTION,
	OptionSections.VIDEO : AppSettings.VIDEO_SECTION,
	OptionSections.GAME : AppSettings.GAME_SECTION,
	OptionSections.APPLICATION : AppSettings.APPLICATION_SECTION,
	OptionSections.CUSTOM : AppSettings.CUSTOM_SECTION,
}

## Locks config names in case of issues with inherited scenes.
## Intentionally put first for initialization.
@export var lock_config_names : bool = false
## Defines text displayed to the user.
@export var option_name : String :
	set(value):
		var _update_config : bool = option_name.to_pascal_case() == key and not lock_config_names
		option_name = value
		if is_inside_tree():
			%OptionLabel.text = "%s%s" % [option_name, label_suffix]
		if _update_config:
			key = option_name.to_pascal_case()
## Defines what section in the config file this option belongs under.
@export var option_section : OptionSections :
	set(value):
		var _update_config : bool = OptionSectionNames[option_section] == section and not lock_config_names
		option_section = value
		if _update_config:
			section = OptionSectionNames[option_section]

@export_group("Config Names")
## Defines the key for this option variable in the config file.
@export var key : String
## Defines the section for this option variable in the config file.
@export var section : String
@export_group("Format")
@export var label_suffix : String = " :"
@export_group("Properties")
## Defines whether the option is editable, or only visible by the user.
@export var editable : bool = true : set = set_editable
## Defines what kind of variable this option stores in the config file.
@export var property_type : Variant.Type = TYPE_BOOL

## It is advised to use an external editor to set the default value in the scene file.
## Godot can experience a bug (caching issue?) that may undo changes.
var default_value
var _connected_nodes : Array

func _on_setting_changed(value) -> void:
	if Engine.is_editor_hint(): return
	PlayerConfig.set_config(section, key, value)
	setting_changed.emit(value)

func _get_setting(default : Variant = null) -> Variant:
	return PlayerConfig.get_config(section, key, default)

func _connect_option_inputs(node) -> void:
	if node in _connected_nodes: return
	if node is Button:
		if node is OptionButton:
			node.item_selected.connect(_on_setting_changed)
		elif node is ColorPickerButton:
			node.color_changed.connect(_on_setting_changed)
		else:
			node.toggled.connect(_on_setting_changed)
		_connected_nodes.append(node)
	if node is Range:
		node.value_changed.connect(_on_setting_changed)
		_connected_nodes.append(node)
	if node is LineEdit or node is TextEdit:
		node.text_changed.connect(_on_setting_changed)
		_connected_nodes.append(node)

func _set_value(value : Variant) -> Variant:
	if value == null:
		return
	for node in get_children():
		if node is Button:
			if node is OptionButton:
				node.select(value as int)
			elif node is ColorPickerButton:
				node.color = value as Color
			else:
				node.button_pressed = value as bool
		if node is Range:
			node.value = value as float
		if node is LineEdit or node is TextEdit:
			node.text = "%s" % value
	return value

func set_value(value : Variant) -> void:
	value = _set_value(value)
	_on_setting_changed(value)

func set_editable(value : bool = true) -> void:
	editable = value
	for node in get_children():
		if node is Button:
			node.disabled = !editable
		if node is Slider or node is SpinBox or node is LineEdit or node is TextEdit:
			node.editable = editable

func _ready() -> void:
	lock_config_names = lock_config_names
	option_section = option_section
	option_name = option_name
	property_type = property_type
	default_value = default_value
	_set_value(_get_setting(default_value))
	for child in get_children():
		_connect_option_inputs(child)
	child_entered_tree.connect(_connect_option_inputs)

func _set(property : StringName, value : Variant) -> bool:
	if property == "value":
		set_value(value)
		return true
	return false

func _get_property_list() -> Array[Dictionary]:
	return [
		{ "name": "value", "type": property_type, "usage": PROPERTY_USAGE_NONE},
		{ "name": "default_value", "type": property_type}
	]
