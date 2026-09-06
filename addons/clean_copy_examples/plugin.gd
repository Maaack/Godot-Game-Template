@tool
class_name CleanCopyExamplesPlugin
extends EditorPlugin

const CopyAndCleanFiles := preload("copier/copy_and_clean_files.gd")

static var instance : CleanCopyExamplesPlugin

var _copy_and_clean_files_scene:PackedScene = preload("copier/copy_and_clean_files.tscn")

func _on_copy_and_edit_completed(target_path:String) -> void:
	CleanCopyExamples.set_copy_path(target_path)

func get_copy_and_clean_scene(examples_directory:String = "") -> CopyAndCleanFiles:
	var copy_and_clean_files_instance:CopyAndCleanFiles = _copy_and_clean_files_scene.instantiate()
	if not examples_directory.is_empty():
		copy_and_clean_files_instance.examples_paths = [examples_directory] as Array[String]
	else:
		copy_and_clean_files_instance.examples_paths = CleanCopyExamples.get_examples_paths()
	copy_and_clean_files_instance.completed.connect(_on_copy_and_edit_completed)
	return copy_and_clean_files_instance

func _enter_tree():
	instance = self

func _exit_tree():
	instance = null
