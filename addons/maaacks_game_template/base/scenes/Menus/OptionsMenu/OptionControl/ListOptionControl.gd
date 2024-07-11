@tool
class_name ListOptionControl
extends OptionControl

## Locks Option Titles from auto-updating when editing Option Values.
## Intentionally put first for initialization.
@export var lock_titles : bool = false
## Defines the list of possible values for the variable
## this option stores in the config file.
@export var option_values : Array :
	set(value) :
		option_values = value
		_on_option_values_changed()

## Defines the list of options displayed to the user.
## Length should match with Option Values.
@export var option_titles : Array[String] :
	set(value):
		option_titles = value
		if is_inside_tree():
			_set_option_list(option_titles)

var custom_option_values : Array

func _on_option_values_changed():
	if option_values.is_empty(): return
	custom_option_values = option_values.duplicate()
	_set_titles_from_values()

func _on_setting_changed(value):
	if value < option_values.size():
		super._on_setting_changed(option_values[value])

func _set_titles_from_values():
	if lock_titles: return
	var mapped_titles : Array[String] = []
	for option_value in custom_option_values:
		mapped_titles.append(_value_title_map(option_value))
	option_titles = mapped_titles

func _value_title_map(value : Variant) -> String:
	return "%s" % value

func _match_value_to_other(value : Variant, other : Variant) -> Variant:
	# Primarily for when the editor saves floats as ints instead
	if value is int and other is float:
		return float(value)
	if value is float and other is int:
		return int(round(value))
	return value

func set_value(value : Variant):
	if option_values.is_empty(): return
	if value == null:
		return super.set_value(-1)
	custom_option_values = option_values.duplicate()
	value = _match_value_to_other(value, custom_option_values.front())
	if value not in custom_option_values:
		custom_option_values.append(value)
		custom_option_values.sort()
	_set_titles_from_values()
	if value not in option_values:
		disable_option(custom_option_values.find(value))
	value = custom_option_values.find(value)
	super.set_value(value)

func _set_option_list(option_titles_list : Array):
	%OptionButton.clear()
	for option_title in option_titles_list:
		%OptionButton.add_item(option_title)

func disable_option(option_index : int, disabled : bool = true):
	%OptionButton.set_item_disabled(option_index, disabled)

func _ready():
	lock_titles = lock_titles
	option_titles = option_titles
	option_values = option_values
	super._ready()
