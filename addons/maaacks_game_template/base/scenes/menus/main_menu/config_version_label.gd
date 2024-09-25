@tool
extends Label
class_name ConfigVersionLabel
## Displays the value of `application/config/version`, set in project settings.

const NO_VERSION_STRING : String = "0.0.0"

## Prefixes the value of `application/config/version` when displaying to the user.
@export var version_prefix : String = "v"

func update_version_label():
	var version_string : String = ProjectSettings.get_setting("application/config/version", NO_VERSION_STRING)
	if version_string.is_empty():
		version_string = NO_VERSION_STRING
	AppLog.version_opened(version_string)
	text = version_prefix + version_string

func _ready():
	update_version_label()
