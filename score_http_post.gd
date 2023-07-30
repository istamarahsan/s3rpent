extends HTTPRequest

signal completed(success: bool)

const endpoint = "https://cybersnakeapi.istamarsan.dev/leaderboard"

func post(name: String, score: int):
	cancel_request()
	var request_created_result = request(
		endpoint,
		[
			"Content-Type: application/json",
			"authorization: Bearer there_is_no_authorization"
		],
		HTTPClient.METHOD_POST,
		JSON.stringify(
			{
				"name": name,
				"score": score
			}
		)
	)
	if request_created_result != OK:
		completed.emit(false)

func _on_request_completed(result, response_code, headers, body):
	completed.emit(result == HTTPRequest.RESULT_SUCCESS and response_code == HTTPClient.RESPONSE_OK)
