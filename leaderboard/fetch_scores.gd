extends HTTPRequest

const _api_url = "https://cybersnakeapi.istamarsan.dev/"

func fetch() -> bool:
	cancel_request()
	var err = request(
		_api_url + "leaderboard",
		["authorization: Bearer there_is_no_authorization"]
	)
	return err == OK
