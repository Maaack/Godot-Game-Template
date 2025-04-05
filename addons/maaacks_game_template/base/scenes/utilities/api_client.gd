extends Node


signal response_received(response_body)
signal request_failed(error)

const RESULT_CANT_CONNECT = "Failed to connect"
const RESULT_CANT_RESOLVE = "Failed to resolve"
const RESULT_CONNECTION_ERROR = "Connection error"
const RESULT_TIMEOUT = "Connection timeout"
const RESULT_SERVER_ERROR = "Server error"
const REQUEST_FAILED = "Error in the request"

@export var api_url : String
@export var request_method : HTTPClient.Method = HTTPClient.METHOD_POST
@export_file("*.txt") var api_key_file : String
## Time in seconds before the request fails due to timeout.
@export var reqeuest_timeout : float = 30.0

@onready var _http_request = $HTTPRequest
@onready var _timeout_timer = $TimeoutTimer

var timed_out : bool = false

func get_http_request():
	return _http_request

func get_api_key() -> String:
	if api_key_file.is_empty(): 
		return ""
	var file := FileAccess.open(api_key_file, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error != OK:
		push_error("An error occurred in the API Key reading. %d" % error)
		return ""
	var content = file.get_as_text()
	file.close()
	return content

func get_api_url() -> String:
	return api_url

func get_api_method() -> int:
	return request_method

func mock_empty_body():
	var form : Dictionary = {}
	return JSON.stringify(form)

func mock_request(body : String):
	await(get_tree().create_timer(10.0).timeout)
	_on_request_completed(HTTPRequest.RESULT_SUCCESS, "200", [], body)

func request(body : String, request_headers : Array = []):
	var local_http_request : HTTPRequest = get_http_request()

	var key : String = get_api_key()
	var url : String = get_api_url()
	var method : int = get_api_method()

	request_headers.append("Content-Type: application/json")
	if key:
		request_headers.append("x-api-key: %s" % key)
	var error = local_http_request.request(url, request_headers, method, body)
	if error != OK:
		emit_signal("request_failed", "An error occurred in the request.")
		push_error("An error occurred in the HTTP request. %d" % error)
	_timeout_timer.start(reqeuest_timeout)

func request_raw(data : PackedByteArray, request_headers : Array = []):
	var local_http_request : HTTPRequest = get_http_request()

	var key : String = get_api_key()
	var url : String = get_api_url()
	var method : int = get_api_method()

	request_headers.append("Content-Type: application/json")
	if key:
		request_headers.append("x-api-key: %s" % key)
	var error = local_http_request.request_raw(url, request_headers, method, data)
	if error != OK:
		emit_signal("request_failed", "An error occurred in the request.")
		push_error("An error occurred in the HTTP request. %d" % error)
	_timeout_timer.start(reqeuest_timeout)

func _on_request_completed(result, response_code, headers, body):
	# If already timed out on client-side, then return.
	if timed_out: return
	_timeout_timer.stop()
	if result == HTTPRequest.RESULT_SUCCESS:
		if body is PackedByteArray:
			var body_string = body.get_string_from_utf8()
			var response = JSON.parse_string(body_string)
			if not (response.has("statusCode") and response.has("body")): return
			var response_body = response["body"]
			var json = JSON.new()
			var error = json.parse(response_body)
			if error == OK:
				response_body = json.data
			if response["statusCode"] != 200:
				emit_signal("request_failed", response_body)
				push_error(response_body)
			else:
				emit_signal("response_received", response_body)
		elif body is String:
			var body_dict = JSON.parse_string(body)
			emit_signal("response_received", body_dict)
	else:
		var error : String
		match(result):
			HTTPRequest.RESULT_CANT_CONNECT:
				error = RESULT_CANT_CONNECT
			HTTPRequest.RESULT_CANT_RESOLVE:
				error = RESULT_CANT_RESOLVE
			HTTPRequest.RESULT_CONNECTION_ERROR:
				error = RESULT_CONNECTION_ERROR
			HTTPRequest.RESULT_TIMEOUT:
				error = RESULT_TIMEOUT
			_:
				error = RESULT_SERVER_ERROR
		push_error("result %d" % result)
		if body is PackedByteArray:
			emit_signal(&"request_failed", body.get_string_from_utf8())
		push_error(result)

func _on_http_request_request_completed(result, response_code, headers, body):
	_on_request_completed(result, response_code, headers, body)

func _on_timeout_timer_timeout():
	timed_out = true
	emit_signal(&"request_failed", "Request timed out.")
	push_warning("Request timed out on the client-side.")
