@tool
extends AcceptDialog

@export_file("*.tscn") var check_version_scene_path : String
@export_dir var input_prompts_directory_path : String

@onready var plugin_label : Label = %PluginLabel
@onready var update_label : Label  = %UpdateLabel
@onready var update_check_box : CheckBox = %UpdateCheckBox
@onready var update_button : Button = %UpdateButton
@onready var copy_check_box : CheckBox = %CopyCheckBox
@onready var copy_button : Button = %CopyButton
@onready var delete_check_box : CheckBox = %DeleteCheckBox
@onready var delete_button : Button = %DeleteButton
@onready var update_paths_check_box : CheckBox = %UpdatePathsCheckBox
@onready var update_paths_button : Button = %UpdatePathsButton
@onready var set_main_scene_check_box : CheckBox = %SetMainSceneCheckBox
@onready var set_main_scene_button : Button = %SetMainSceneButton
@onready var set_default_theme_check_box : CheckBox = %SetDefaultThemeCheckBox
@onready var set_default_theme_button : Button = %SetDefaultThemeButton
@onready var add_input_icons_check_box : CheckBox = %AddInputIconsCheckBox
@onready var add_input_icons_button : Button = %AddInputIconsButton

func _refresh_plugin_details() -> void:
	for enabled_plugin in ProjectSettings.get_setting("editor_plugins/enabled"):
		if enabled_plugin.contains(MaaacksGameTemplatePlugin.get_settings_path()):
			var config := ConfigFile.new()
			var error = config.load(enabled_plugin)
			if error != OK:
				return
			var current_plugin_version : String = config.get_value("plugin", "version", "0.0.0")
			var plugin_name : String = config.get_value("plugin", "name", "Plugin")
			plugin_label.text = "%s v%s" % [plugin_name, current_plugin_version]

func _show_plugin_versions_match() -> void:
	update_label.text = "Using Latest Version"
	update_check_box.button_pressed = true
	update_button.disabled = true

func _enable_update_plugin_tool_option(tag_name : String) -> void:
	update_label.text = "Update to Latest Version v%s" % tag_name
	update_button.disabled = false

func _open_check_plugin_version() -> void:
	if check_version_scene_path.is_empty():
		push_warning("Variable \"check_version_scene_path\" is not set")
		return
	if ProjectSettings.get_setting(MaaacksGameTemplatePlugin.get_settings_path() + "disable_update_check", false):
		update_label.text = "Check for Latest Version"
		update_button.disabled = false
		return
	var check_version_scene : PackedScene = load(check_version_scene_path)
	var check_version_instance : Node = check_version_scene.instantiate()
	check_version_instance.auto_start = true
	check_version_instance.new_version_detected.connect(_enable_update_plugin_tool_option)
	check_version_instance.versions_matched.connect(_show_plugin_versions_match)
	add_child(check_version_instance)

func _refresh_copy_and_delete_examples() -> void:
	var examples_path = MaaacksGameTemplatePlugin.instance.get_plugin_examples_path()
	if MaaacksGameTemplatePlugin.get_copy_path() != examples_path:
		copy_check_box.button_pressed = true
	var dir := DirAccess.open("res://")
	if dir.dir_exists(examples_path):
		copy_button.disabled = false
		delete_button.disabled = false
	else:
		delete_check_box.button_pressed = true

func _refresh_update_autoload_paths() -> void:
	update_paths_check_box.button_pressed = MaaacksGameTemplatePlugin.instance.are_autoload_paths_updated()
	update_paths_button.disabled = false

func _refresh_main_scene() -> void:
	if MaaacksGameTemplatePlugin.instance.is_main_scene_set():
		set_main_scene_check_box.button_pressed = true
	else:
		set_main_scene_button.disabled = false

func _refresh_default_theme() -> void:
	set_default_theme_button.disabled = false
	if ProjectSettings.get_setting("gui/theme/custom", "") != "":
		set_default_theme_check_box.button_pressed = true

func _refresh_input_prompts() -> void:
	if input_prompts_directory_path.is_empty():
		push_warning("Variable \"input_prompts_directory_path\" is not set")
		return
	if DirAccess.dir_exists_absolute(input_prompts_directory_path):
		add_input_icons_check_box.button_pressed = true
	add_input_icons_button.disabled = false

func _refresh_options():
	_refresh_plugin_details()
	_open_check_plugin_version()
	_refresh_copy_and_delete_examples()
	_refresh_update_autoload_paths()
	_refresh_main_scene()
	_refresh_default_theme()
	_refresh_input_prompts()

func _ready():
	_refresh_options()

func _on_update_button_pressed():
	if ProjectSettings.get_setting(MaaacksGameTemplatePlugin.get_settings_path() + "disable_update_check", false):
		ProjectSettings.set_setting(MaaacksGameTemplatePlugin.get_settings_path() + "disable_update_check", false)
		_open_check_plugin_version()
		return
	else:
		tree_exited.connect(func(): MaaacksGameTemplatePlugin.instance.open_update_plugin())
		queue_free()

func _on_copy_button_pressed():
	tree_exited.connect(func(): MaaacksGameTemplatePlugin.instance.open_copy_and_edit_dialog())
	queue_free()

func _on_delete_button_pressed():
	tree_exited.connect(func(): MaaacksGameTemplatePlugin.instance.open_delete_examples_short_confirmation_dialog())
	queue_free()

func _on_update_paths_button_pressed():
	MaaacksGameTemplatePlugin.instance.update_autoload_paths(MaaacksGameTemplatePlugin.get_copy_path())
	_refresh_update_autoload_paths()
	update_paths_button.disabled = true
	await get_tree().create_timer(1.0).timeout
	update_paths_button.disabled = false

func _on_set_main_scene_button_pressed():
	tree_exited.connect(func(): MaaacksGameTemplatePlugin.instance.open_main_scene_confirmation_dialog(MaaacksGameTemplatePlugin.get_copy_path()))
	queue_free()

func _on_set_default_theme_button_pressed():
	tree_exited.connect(func(): MaaacksGameTemplatePlugin.instance.open_theme_selection_dialog(MaaacksGameTemplatePlugin.get_copy_path()))
	queue_free()

func _on_add_input_icons_button_pressed():
	tree_exited.connect(func(): MaaacksGameTemplatePlugin.instance.open_input_icons_dialog())
	queue_free()
