class_name AppLog
extends Node
## Logs application version and opened count through [Config].

const APP_LOG_SECTION = "AppLog"
const APP_OPENED = "AppOpened"
const FIRST_VERSION_OPENED = "FirstVersionOpened"
const LAST_VERSION_OPENED = "LastVersionOpened"
const NO_VERSION_STRING : String = "0.0.0"


static func set_first_version_opened(value : String) -> void:
	var first_version_opened = Config.get_config(APP_LOG_SECTION, FIRST_VERSION_OPENED, NO_VERSION_STRING)
	if first_version_opened != NO_VERSION_STRING:
		return
	Config.set_config(APP_LOG_SECTION, FIRST_VERSION_OPENED, value)

static func set_last_version_opened(value : String) -> void:
	Config.set_config(APP_LOG_SECTION, LAST_VERSION_OPENED, value)

static func version_opened(version : String) -> void:
	set_first_version_opened(version)
	set_last_version_opened(version)

static func log_config_version() -> void:
	var config_version : String = ProjectSettings.get_setting("application/config/version", NO_VERSION_STRING)
	if config_version.is_empty():
		config_version = NO_VERSION_STRING
	AppLog.version_opened(config_version)

static func app_opened() -> void:
	var total_app_opened = Config.get_config(APP_LOG_SECTION, APP_OPENED, 0)
	total_app_opened += 1
	Config.set_config(APP_LOG_SECTION, APP_OPENED, total_app_opened)
	log_config_version()
