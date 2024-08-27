class_name Config
extends Node
## Interface for a single configuration file through [ConfigFile].

const CONFIG_FILE_LOCATION := "user://config.cfg"
const DEFAULT_CONFIG_FILE_LOCATION := "res://default_config.cfg"

static var config_file : ConfigFile

static func _init():
	load_config_file()

static func _save_config_file() -> void:
	var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
	if save_error:
		print("save config file failed with error %d" % save_error)

static func load_config_file() -> void:
	if config_file != null:
		return
	config_file = ConfigFile.new()
	var load_error : int = config_file.load(CONFIG_FILE_LOCATION)
	if load_error:
		var load_default_error : int = config_file.load(DEFAULT_CONFIG_FILE_LOCATION)
		if load_default_error:
			print("loading default config file failed with error %d" % load_default_error)
		var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
		if save_error:
			print("save config file failed with error %d" % save_error)

static func set_config(section: String, key: String, value) -> void:
	load_config_file()
	config_file.set_value(section, key, value)
	_save_config_file()

static func get_config(section: String, key: String, default = null) -> Variant:
	load_config_file()
	return config_file.get_value(section, key, default)

static func has_section(section: String):
	load_config_file()
	return config_file.has_section(section)

static func erase_section(section: String):
	if has_section(section):
		config_file.erase_section(section)
		_save_config_file()

static func erase_section_key(section: String, key: String):
	if has_section(section):
		config_file.erase_section_key(section, key)
		_save_config_file()

static func get_section_keys(section: String):
	load_config_file()
	if config_file.has_section(section):
		return config_file.get_section_keys(section)
	return PackedStringArray()
