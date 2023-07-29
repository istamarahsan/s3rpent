extends HTTPRequest

const _api_url = "https://cybersnakeapi.istamarsan.dev/"

func fetch():
	cancel_request()
	request(
		_api_url + "leaderboard",
		["authorization: Bearer there_is_no_authorization"]
	)
