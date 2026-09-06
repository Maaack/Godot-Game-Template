class_name CleanCopyExamples
extends RefCounted

const PROJECT_SETTINGS_PATH := "clean_copy_examples/"
const COPY_SCENE_RELATIVE_PATH := "copier/copy_and_clean_files.tscn"
const EXAMPLES_PATHS_KEY = "examples_paths"
const COPY_PATH_KEY = "copy_path"
const CopyAndClean = preload("copier/copy_and_clean_files.gd")

static var _copy_and_edit_files_scene:PackedScene = preload(COPY_SCENE_RELATIVE_PATH)

static func get_copy_path(default_path : String = "") -> String:
	var copy_path = ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + COPY_PATH_KEY, default_path)
	if not (copy_path.is_empty() or copy_path.ends_with("/")):
		copy_path += "/"
	return copy_path

static func set_copy_path(copy_path : String) -> void:
	ProjectSettings.set_setting(PROJECT_SETTINGS_PATH + COPY_PATH_KEY, copy_path)
	ProjectSettings.save()

static func get_examples_paths() -> Array:
	return ProjectSettings.get_setting(PROJECT_SETTINGS_PATH + EXAMPLES_PATHS_KEY, [])

static func are_examples_copied() -> bool:
	return not get_copy_path().is_empty()

static func are_examples_deleted() -> bool:
	var dir := DirAccess.open("res://")
	var examples_paths := get_examples_paths()
	for examples_path in examples_paths:
		if not dir.dir_exists(examples_path):
			return false
	return true

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

static func _on_copy_and_edit_completed(target_path:String) -> void:
	set_copy_path(target_path)

static func get_copy_and_clean_scene(examples_directory:String = "") -> CopyAndClean:
	var copy_and_edit_file_instance : CopyAndClean = _copy_and_edit_files_scene.instantiate()
	if not examples_directory.is_empty():
		copy_and_edit_file_instance.examples_paths = [examples_directory]
	else:
		copy_and_edit_file_instance.examples_paths = get_examples_paths()
	copy_and_edit_file_instance.completed.connect(_on_copy_and_edit_completed)
	return copy_and_edit_file_instance
