extends Node

signal link_available

var _cache: String = ""
var _available: bool = false
var _req: HTTPRequest

const form_url_endpoint = "https://cybersnakeapi.istamarsan.dev/feedback"

func _ready():
	_req = HTTPRequest.new()
	add_child(_req)
	_req.request_completed.connect(_request_completed)
	_req.request(
		form_url_endpoint,
		["authorization: Bearer there_is_no_authorization"]
	)

func is_available() -> bool:
	return _available

func get_feedback_form_link() -> String:
	return _cache if _available else ""

func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())
	var url: String = data["formUrl"]
	
	_cache = url
	_available = true
	
	link_available.emit()
