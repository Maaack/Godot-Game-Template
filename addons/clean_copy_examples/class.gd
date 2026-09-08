class_name CleanCopyExamples
extends RefCounted

const PROJECT_SETTINGS_PATH := "clean_copy_examples/"
const COPY_SCENE_RELATIVE_PATH := "copier/copy_and_clean_files.tscn"
const EXAMPLES_PATHS_KEY = "examples_paths"
const COPY_PATH_KEY = "copy_path"
const REPLACE_STRINGS_KEY = "replace_strings"
const CopyAndCleanFiles := preload("copier/copy_and_clean_files.gd")
const _COPY_AND_CLEAN_FILES_SCENE:PackedScene = preload("copier/copy_and_clean_files.tscn")

static func get_copy_path(default_path : String = "") -> String:
	var copy_path = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + COPY_PATH_KEY, default_path)
	if not (copy_path.is_empty() or copy_path.ends_with("/")):
		copy_path += "/"
	return copy_path

static func set_copy_path(copy_path : String) -> void:
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + COPY_PATH_KEY, copy_path)
	ProjectSettings.save()

static func get_examples_paths() -> Array[String]:
	var default_value : Array[String] = []
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + EXAMPLES_PATHS_KEY, default_value)

static func get_replace_strings() -> Dictionary[String, String]:
	var default_value : Dictionary[String, String] = {}
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + REPLACE_STRINGS_KEY, default_value)

static func are_examples_copied() -> bool:
	return not get_copy_path().is_empty()

static func are_all_examples_deleted() -> bool:
	var dir := DirAccess.open("res://")
	var examples_paths := get_examples_paths()
	for examples_path in examples_paths:
		if dir.dir_exists(examples_path):
			return false
	return true

static func are_any_examples_deleted() -> bool:
	var dir := DirAccess.open("res://")
	var examples_paths := get_examples_paths()
	for examples_path in examples_paths:
		if not dir.dir_exists(examples_path):
			return false
	return true

static func delete_examples() -> void:
	if are_all_examples_deleted():
		return
	var examples_paths := get_examples_paths()
	var dir := DirAccess.open("res://")
	for examples_path in examples_paths:
		if dir.dir_exists(examples_path):
			var global_path := ProjectSettings.globalize_path(examples_path)
			OS.move_to_trash(global_path)
	EditorInterface.get_resource_filesystem().scan()

static func _on_copy_and_edit_completed(target_path:String) -> void:
	CleanCopyExamples.set_copy_path(target_path)

static func get_copy_and_clean_scene(examples_directory:String = "", replace_strings_map : Dictionary[String, String] = {}) -> CopyAndCleanFiles:
	var copy_and_clean_files_instance:CopyAndCleanFiles = _COPY_AND_CLEAN_FILES_SCENE.instantiate()
	if not examples_directory.is_empty():
		copy_and_clean_files_instance.examples_paths = [examples_directory] as Array[String]
	else:
		copy_and_clean_files_instance.examples_paths = CleanCopyExamples.get_examples_paths()
	if not replace_strings_map.is_empty():
		copy_and_clean_files_instance.replace_strings_map = replace_strings_map
	else:
		copy_and_clean_files_instance.replace_strings_map = CleanCopyExamples.get_replace_strings()
	copy_and_clean_files_instance.completed.connect(_on_copy_and_edit_completed)
	return copy_and_clean_files_instance

static func add_examples(examples_directory:String):
	var example_paths := get_examples_paths()
	example_paths.append(examples_directory)
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + EXAMPLES_PATHS_KEY, example_paths)
	ProjectSettings.save()

static func remove_examples(examples_directory:String):
	var example_paths := get_examples_paths()
	example_paths.erase(examples_directory)
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + EXAMPLES_PATHS_KEY, example_paths)
	ProjectSettings.save()

static func add_replace_string(find:String, replace:String):
	var replace_strings := get_replace_strings()
	replace_strings[find] = replace
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + REPLACE_STRINGS_KEY, replace_strings)
	ProjectSettings.save()

static func remove_replace_string(find:String, _replace:String=""):
	var replace_strings := get_replace_strings()
	replace_strings.erase(find)
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + REPLACE_STRINGS_KEY, replace_strings)
	ProjectSettings.save()
