@tool
extends Label
class_name ConfigVersionLabel
## Displays the value of `application/config/version`, set in project settings.

const NO_VERSION_STRING : String = "0.0.0"

## Prefixes the value of `application/config/version` when displaying to the user.
@export var version_prefix : String = "v"

func update_version_label() -> void:
	var config_version : String = ProjectSettings.get_setting("application/config/version", NO_VERSION_STRING)
	if config_version.is_empty():
		config_version = NO_VERSION_STRING
	text = version_prefix + config_version

func _ready() -> void:
	update_version_label()
