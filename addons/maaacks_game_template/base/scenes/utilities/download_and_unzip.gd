class_name DownloadAndUnzip
extends Node

signal response_received(response_body)
signal request_failed(error)

const TEMPORARY_ZIP_PATH = "res://temp.zip"

@export var zip_url : String
@export_dir var extract_path : String
@export_group("Advanced Settings")
@export var request_timeout : float = 10.0
@export var zip_file_path : String = TEMPORARY_ZIP_PATH

@onready var _http_request = $HTTPRequest
@onready var _timeout_timer = $TimeoutTimer

var timed_out : bool = false

func get_http_request():
	return _http_request

func get_zip_url() -> String:
	return zip_url

func _zip_exists() -> bool:
	return FileAccess.file_exists(zip_file_path)

func get_request_method() -> int:
	return HTTPClient.METHOD_GET

func request(body : String = "", request_headers : Array = []):
	var local_http_request : HTTPRequest = get_http_request()

	var url : String = get_zip_url()
	var method : int = get_request_method()

	var error = local_http_request.request(url, request_headers, method, body)
	if error != OK:
		emit_signal("request_failed", "An error occurred in the request.")
		push_error("An error occurred in the HTTP request. %d" % error)
	_timeout_timer.start(request_timeout)

func _delete_zip_file():
	DirAccess.remove_absolute(zip_file_path)

func _save_zip_file(body : PackedByteArray):
	var file = FileAccess.open(zip_file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file")
		return
	file.store_buffer(body)
	file.close()

func _extract_path_exists() -> bool:
	return DirAccess.dir_exists_absolute(extract_path)

func _make_extract_path():
	var err := DirAccess.make_dir_absolute(extract_path)
	if err != OK:
		push_error("Failed to make extract directory")

func _extract_files():
	if not _zip_exists():
		push_error("Zip file does not exist")
	if not _extract_path_exists(): _make_extract_path()
	var zip_reader := ZIPReader.new()
	var err = zip_reader.open(zip_file_path)
	if err != OK:
		return
	var file_paths := zip_reader.get_files()
	var extract_path_dir := extract_path
	if not extract_path_dir.ends_with("/"):
		extract_path_dir += "/"
	for file_path in file_paths:
		var file_contents = zip_reader.read_file(file_path)
		var full_path := extract_path_dir + file_path
		if full_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(full_path)
		else:
			var file_access := FileAccess.open(full_path, FileAccess.WRITE)
			file_access.store_buffer(file_contents)
			file_access.close()
	zip_reader.close()

func _on_request_completed(result, response_code, headers, body):
	# If already timed out on client-side, then return.
	if timed_out: return
	_timeout_timer.stop()
	if _zip_exists(): _delete_zip_file()
	if result == HTTPRequest.RESULT_SUCCESS:
		print(typeof(body))
		if body is PackedByteArray:
			_save_zip_file(body)
			_extract_files()
			_delete_zip_file()
			emit_signal("response_received", body)
	else:
		if body is PackedByteArray:
			emit_signal(&"request_failed", body.get_string_from_utf8())
		push_error(result)

func _on_http_request_request_completed(result, response_code, headers, body):
	_on_request_completed(result, response_code, headers, body)

func _on_timeout_timer_timeout():
	timed_out = true
	emit_signal(&"request_failed", "Request timed out.")
	push_warning("Request timed out on the client-side.")
