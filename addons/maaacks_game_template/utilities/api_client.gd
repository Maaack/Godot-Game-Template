@tool
extends Node


signal response_received(response_body)
signal request_failed(error)

const RESULT_CANT_CONNECT = "Failed to connect"
const RESULT_CANT_RESOLVE = "Failed to resolve"
const RESULT_CONNECTION_ERROR = "Connection error"
const RESULT_TIMEOUT = "Connection timeout"
const RESULT_SERVER_ERROR = "Server error"
const REQUEST_FAILED = "Error in the request"
const REQUEST_TIMEOUT = "Request timed out on the client side"
const URL_NOT_SET = "URL parameter is not set"
const PARSE_FAILED = "Parsing failed"

## Location of the API endpoint.
@export var api_url : String
## HTTP request method to use. Typically GET or POST.
@export var request_method : HTTPClient.Method = HTTPClient.METHOD_POST
@export_group("Advanced")
## Location of an API key file, if authorization is required by the endpoint.
@export_file("*.txt") var api_key_file : String
## Time in seconds before the request fails due to timeout.
@export var request_timeout : float = 0.0
@export var _send_request_action : bool = false :
	set(value):
		if value and Engine.is_editor_hint():
			request()
# For Godot 4.4
# @export_tool_button("Send Request") var _send_request_action = request


@onready var _http_request : HTTPRequest = $HTTPRequest
@onready var _timeout_timer : Timer= $TimeoutTimer

## State flag for whether the connection has timed out on the client-side.
var timed_out : bool = false

func get_http_request() -> HTTPRequest:
	return _http_request

func get_api_key() -> String:
	if api_key_file.is_empty(): 
		return ""
	var file := FileAccess.open(api_key_file, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error != OK:
		push_error("API Key reading error: %d" % error)
		return ""
	var content = file.get_as_text()
	file.close()
	return content

func get_api_url() -> String:
	return api_url

func get_api_method() -> int:
	return request_method

func mock_empty_body() -> String:
	var form : Dictionary = {}
	return JSON.stringify(form)

func mock_request(body : String):
	await(get_tree().create_timer(10.0).timeout)
	_on_request_completed(HTTPRequest.RESULT_SUCCESS, "200", [], body)

func request(body : String = "", request_headers : Array = []) -> void:
	var local_http_request : HTTPRequest = get_http_request()
	var key : String = get_api_key()
	var url : String = get_api_url()
	var method : int = get_api_method()
	if url.is_empty():
		request_failed.emit(URL_NOT_SET)
		push_error(URL_NOT_SET)
		return
	request_headers.append("Content-Type: application/json")
	if key:
		request_headers.append("x-api-key: %s" % key)
	if request_timeout > 0.0:
		local_http_request.timeout = request_timeout
	var error = local_http_request.request(url, request_headers, method, body)
	if error != OK:
		request_failed.emit(REQUEST_FAILED)
		push_error("HTTP Request error: %d" % error)
		return
	if request_timeout > 0.0:
		_timeout_timer.start(request_timeout + 1.0)

func request_raw(data : PackedByteArray = [], request_headers : Array = []) -> void:
	var local_http_request : HTTPRequest = get_http_request()
	var key : String = get_api_key()
	var url : String = get_api_url()
	var method : int = get_api_method()
	if url.is_empty():
		request_failed.emit(URL_NOT_SET)
		push_error(URL_NOT_SET)
		return
	request_headers.append("Content-Type: application/json")
	if key:
		request_headers.append("x-api-key: %s" % key)
	if request_timeout > 0.0:
		local_http_request.timeout = request_timeout
	var error = local_http_request.request_raw(url, request_headers, method, data)
	if error != OK:
		request_failed.emit(REQUEST_FAILED)
		push_error("HTTP Request error: %d" % error)
		return
	if request_timeout > 0.0:
		_timeout_timer.start(request_timeout + 1.0)

func _on_request_completed(result, response_code, headers, body) -> void:
	# If already timed out on client-side, then return.
	if timed_out: return
	_timeout_timer.stop()
	if result == HTTPRequest.RESULT_SUCCESS:
		var body_string : String
		if body is PackedByteArray:
			body_string = body.get_string_from_utf8()
		elif body is String:
			body_string = body
		var json := JSON.new()
		var error = json.parse(body_string)
		if error != OK:
			request_failed.emit(PARSE_FAILED)
			push_error("Parse error: %d" % error)
			return
		var parsed_data = json.data
		response_received.emit(json.data)
	else:
		var error_message : String
		match(result):
			HTTPRequest.RESULT_CANT_CONNECT:
				error_message = RESULT_CANT_CONNECT
			HTTPRequest.RESULT_CANT_RESOLVE:
				error_message = RESULT_CANT_RESOLVE
			HTTPRequest.RESULT_CONNECTION_ERROR:
				error_message = RESULT_CONNECTION_ERROR
			HTTPRequest.RESULT_TIMEOUT:
				error_message = RESULT_TIMEOUT
			_:
				error_message = RESULT_SERVER_ERROR
		request_failed.emit(error_message)
		push_error("HTTP Result error: %d" % result)

func _on_http_request_request_completed(result, response_code, headers, body) -> void:
	_on_request_completed(result, response_code, headers, body)

func _on_timeout_timer_timeout() -> void:
	timed_out = true
	request_failed.emit(REQUEST_TIMEOUT)
	push_warning(REQUEST_TIMEOUT)
