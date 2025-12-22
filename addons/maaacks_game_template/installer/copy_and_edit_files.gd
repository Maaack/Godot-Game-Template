@tool
extends Node
## Script for automatically copying Godot scenes and scripts without UIDs.

signal canceled
signal completed(target_path : String)

const UID_PREG_MATCH = r'uid="uid:\/\/[0-9a-z]+" '
const RUNNING_CHECK_DELAY : float = 0.25
const RESAVING_DELAY : float = 1.0
const RAW_COPY_EXTENSIONS : Array = ["gd", "md", "txt"]
const OMIT_COPY_EXTENSIONS : Array = ["uid"]
const REPLACE_CONTENT_EXTENSIONS : Array = ["gd", "tscn", "tres", "md"]

@onready var destination_dialog : FileDialog = $DestinationDialog

@export_dir var relative_path : String :
	set(value):
		relative_path = value
		if not relative_path.ends_with("/"):
			relative_path += "/"
@export var replace_strings_map : Dictionary
@export var visible : bool = true :
	set(value):
		visible = value
		if is_inside_tree():
			destination_dialog.visible = visible

func show() -> void:
	visible = true

func hide() -> void:
	visible = false

func close() -> void:
	queue_free()

func _remove_uids(content : String) -> String:
	var regex = RegEx.new()
	regex.compile(UID_PREG_MATCH)
	return regex.sub(content, "", true)

func _replace_paths(content : String, target_path : String) -> String:
	return content.replace(relative_path.trim_prefix("res://"), target_path.trim_prefix("res://"))

func _replace_strings(content : String) -> String:
	for key in replace_strings_map:
		var value : String = replace_strings_map[key]
		content = content.replace(key, value)
	return content

func _replace_content(content : String, target_path : String) -> String:
	var replaced_content : String
	replaced_content = _remove_uids(content)
	replaced_content = _replace_paths(replaced_content, target_path)
	replaced_content = _replace_strings(replaced_content)
	return replaced_content

func _replace_file_contents(file_path : String, target_path : String) -> void:
	var extension : String = file_path.get_extension()
	if extension not in REPLACE_CONTENT_EXTENSIONS:
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("plugin error - null file: `%s`" % file_path)
		return
	var original_content = file.get_as_text()
	file.close()
	var replaced_content := _replace_content(original_content, target_path)
	if replaced_content == original_content: return
	file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(replaced_content)
	file.close()

func _save_resource(resource_path : String, resource_destination : String, whitelisted_extensions : PackedStringArray = []) -> Error:
	var extension : String = resource_path.get_extension()
	if whitelisted_extensions.size() > 0:
		if not extension in whitelisted_extensions:
			return OK
	if extension == "import":
		# skip import files
		return OK
	var file_object = load(resource_path)
	if file_object is Resource:
		var possible_extensions = ResourceSaver.get_recognized_extensions(file_object)
		if possible_extensions.has(extension):
			return ResourceSaver.save(file_object, resource_destination, ResourceSaver.FLAG_CHANGE_PATH)
		else:
			return ERR_FILE_UNRECOGNIZED
	else:
		return ERR_FILE_UNRECOGNIZED
	return OK

func _raw_copy_file_path(file_path : String, destination_path : String) -> Error:
	var dir := DirAccess.open("res://")
	var error := dir.copy(file_path, destination_path)
	return error

func _copy_file_path(file_path : String, destination_path : String, target_path : String) -> Error:
	var error : Error
	if file_path.get_extension() in OMIT_COPY_EXTENSIONS:
		return error
	if file_path.get_extension() in RAW_COPY_EXTENSIONS:
		error = _raw_copy_file_path(file_path, destination_path)
	else:
		error = _save_resource(file_path, destination_path)
		if error == ERR_FILE_UNRECOGNIZED:
			error = _raw_copy_file_path(file_path, destination_path)
	if not error:
		_replace_file_contents(destination_path, target_path)
	return error

func _copy_directory_path(dir_path : String, target_path : String) -> void:
	if not dir_path.ends_with("/"):
		dir_path += "/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var error : Error
		while file_name != "" and error == 0:
			var file_relative_path = dir_path.trim_prefix(relative_path)
			var destination_path = target_path + file_relative_path + file_name
			var full_file_path = dir_path + file_name
			if dir.current_is_dir():
				if not dir.dir_exists(destination_path):
					error = dir.make_dir(destination_path)
				_copy_directory_path(full_file_path, target_path)
			else:
				error = _copy_file_path(full_file_path, destination_path, target_path)
			file_name = dir.get_next()
		if error:
			push_error("plugin error - copying path: %s" % error)
	else:
		push_error("plugin error - accessing path: %s" % dir_path)

func _complete(target_path : String) -> void:
	completed.emit(target_path)
	close()

func _wait_for_scan_and_complete(target_path : String) -> void:
	var timer: Timer = Timer.new()
	var callable := func():
		if EditorInterface.get_resource_filesystem().is_scanning(): return
		timer.stop()
		_complete(target_path)
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(RUNNING_CHECK_DELAY)

func _delayed_saving_and_next_prompt(target_path : String) -> void:
	var timer: Timer = Timer.new()
	var callable := func():
		timer.stop()
		EditorInterface.save_all_scenes()
		EditorInterface.get_resource_filesystem().scan()
		_wait_for_scan_and_complete(target_path)
		timer.queue_free()
	timer.timeout.connect(callable)
	add_child(timer)
	timer.start(RESAVING_DELAY)

func _copy_to_directory(target_path : String) -> void:
	if not target_path.ends_with("/"):
		target_path += "/"
	_copy_directory_path(relative_path, target_path)
	_delayed_saving_and_next_prompt(target_path)

func _on_destination_dialog_dir_selected(dir):
	_copy_to_directory(dir)

func _on_destination_dialog_canceled():
	canceled.emit()
	close()
