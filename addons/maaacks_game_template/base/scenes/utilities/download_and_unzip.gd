class_name DownloadAndUnzip
extends Node

signal response_received(response_body)
signal request_failed(error)

const TEMPORARY_ZIP_PATH = "res://temp.zip"
enum Stage{
	NONE,
	DOWNLOAD,
	EXTRACT,
	DELETE,
}

@export var zip_url : String
@export_dir var extract_path : String
@export_group("Advanced Settings")
@export var request_timeout : float = 10.0
@export var zip_file_path : String = TEMPORARY_ZIP_PATH
@export var delete_zip_file : bool = true
@export var process_time_ratio : float = 0.75

@onready var _http_request : HTTPRequest = $HTTPRequest
@onready var _timeout_timer : Timer= $TimeoutTimer

var timed_out : bool = false
var stage : Stage = Stage.NONE
var zip_reader : ZIPReader = ZIPReader.new()
var zipped_file_paths : PackedStringArray
var extracted_file_paths : Array[String]


func get_http_request():
	return _http_request

func get_zip_url() -> String:
	return zip_url

func _zip_exists() -> bool:
	return FileAccess.file_exists(zip_file_path)

func get_request_method() -> int:
	return HTTPClient.METHOD_GET

func request(body : String = "", request_headers : Array = []):
	if stage == Stage.DOWNLOAD:
		push_warning("Download in progress")
		return
	if _zip_exists():
		_extract_files.call_deferred()
		return
	var local_http_request : HTTPRequest = get_http_request()

	var url : String = get_zip_url()
	var method : int = get_request_method()

	var error = local_http_request.request(url, request_headers, method, body)
	if error != OK:
		emit_signal("request_failed", "An error occurred in the request.")
		push_error("An error occurred in the HTTP request. %d" % error)
	_timeout_timer.start(request_timeout)
	stage = Stage.DOWNLOAD

func _delete_zip_file():
	if not delete_zip_file: return
	if stage == Stage.DELETE:
		push_warning("Extract in progress")
		return
	stage = Stage.DELETE
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
	if stage == Stage.EXTRACT:
		push_warning("Extract in progress")
		return
	stage = Stage.EXTRACT
	if not _zip_exists():
		push_error("Zip file does not exist")
	if not _extract_path_exists(): _make_extract_path()
	var err = zip_reader.open(zip_file_path)
	if err != OK:
		return
	zipped_file_paths = zip_reader.get_files()

func _on_request_completed(result, response_code, headers, body):
	# If already timed out on client-side, then return.
	if timed_out: return
	_timeout_timer.stop()
	if _zip_exists(): _delete_zip_file()
	if result == HTTPRequest.RESULT_SUCCESS:
		print(typeof(body))
		if body is PackedByteArray:
			_save_zip_file(body)
			_extract_files.call_deferred()
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

func get_progress():
	if stage == Stage.DOWNLOAD:
		return get_download_progress()
	else:
		return get_extraction_progress()

func get_extraction_progress() -> float:
	if zipped_file_paths.size() == 0:
		return 0.0
	return float(extracted_file_paths.size()) / float(zipped_file_paths.size())

func get_download_progress() -> float:
	var body_size := _http_request.get_body_size()
	if body_size < 1: return 0.0
	return float($HTTPRequest.get_downloaded_bytes()) / float(body_size)

func _zipped_files_remaining() -> int:
	return zipped_file_paths.size() - extracted_file_paths.size()

func _extract_next_zipped_file():
	var path_index = extracted_file_paths.size()
	var zipped_file_path := zipped_file_paths.get(path_index)
	var extract_path_dir := extract_path
	if not extract_path_dir.ends_with("/"):
		extract_path_dir += "/"
	var file_contents = zip_reader.read_file(zipped_file_path)
	var full_path := extract_path_dir + zipped_file_path
	if full_path.ends_with("/"):
		DirAccess.make_dir_recursive_absolute(full_path)
	else:
		var file_access := FileAccess.open(full_path, FileAccess.WRITE)
		file_access.store_buffer(file_contents)
		file_access.close()
	extracted_file_paths.append(full_path)

func _process(delta):
	if stage == Stage.EXTRACT:
		var frame_start_time : float = Time.get_unix_time_from_system()
		var frame_time : float = 0.0
		while (frame_time < delta * process_time_ratio):
				if _zipped_files_remaining() == 0:
					zip_reader.close()
					_delete_zip_file()
					stage = Stage.NONE
					break
				_extract_next_zipped_file()
				frame_time = Time.get_unix_time_from_system() - frame_start_time
