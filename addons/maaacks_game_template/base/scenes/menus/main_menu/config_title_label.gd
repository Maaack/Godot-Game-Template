@tool
extends Label
class_name ConfigNameLabel
## Displays the value of `application/config/name`, set in project settings.

const NO_NAME_STRING : String = "Title"

func update_name_label():
	var version_string : String = ProjectSettings.get_setting("application/config/name", NO_NAME_STRING)
	if version_string.is_empty():
		version_string = NO_NAME_STRING
	if text.is_empty() or text == NO_NAME_STRING:
		text = version_string

func _ready():
	update_name_label()
