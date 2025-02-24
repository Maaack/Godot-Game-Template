@tool
extends Label
class_name ConfigNameLabel
## Displays the value of `application/config/name`, set in project settings.

const NO_NAME_STRING : String = "Title"

@export var lock : bool = false

func update_name_label():
	if lock: return
	var config_name : String = ProjectSettings.get_setting("application/config/name", NO_NAME_STRING)
	if config_name.is_empty():
		config_name = NO_NAME_STRING
	text = config_name

func _ready():
	update_name_label()
