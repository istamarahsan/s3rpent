extends Control

signal request_replay
signal quit_to_main_menu

@export var url: String

@onready var state_hook: StateHook = $StateHook as StateHook
@onready var score_upload_form: Control = $LeaderboardThings as Control
@onready var leaderboard_label: Label = $LeaderboardThings/VBoxContainer/Panel/LeaderboardContent as Label
@onready var game_over_buttons: Control = $Stats/Panel/MarginContainer/VBoxContainer/GameOverButtons as Control
@onready var player_alias_input: LineEdit = $LeaderboardThings/VBoxContainer/HBoxContainer/LineEdit as LineEdit
@onready var leaderboard_post: HTTPRequest = $LeaderboardPost as HTTPRequest
@onready var leaderboard_fetch: HTTPRequest = $LeaderboardFetch as HTTPRequest
@onready var conversion_timer_label: Label = $ConversionTimeRemaining

func _ready():
	score_upload_form.visible = false
	game_over_buttons.visible = false

func _upload_score(score: int, player_alias: String):
	leaderboard_post.request(
		url + "leaderboard", 
		[
			"Content-Type: application/json", 
			"authorization: Bearer there_is_no_authorization"
		], 
		HTTPClient.METHOD_POST, 
		JSON.stringify(
			{
				"name": player_alias,
				"score": score
			}
	))

func _get_leaderboard():
	leaderboard_label.text = "loading..."
	leaderboard_fetch.cancel_request()
	leaderboard_fetch.request(
		url + "leaderboard",
		["authorization: Bearer there_is_no_authorization"]
	)

func _on_save_score_button_button_up():
	score_upload_form.visible = true
	_get_leaderboard()

func _on_replay_button_button_up():
	request_replay.emit()

func _on_submit_score_button_up():
	var input: String = player_alias_input.text
	if input == "" or not input.is_valid_identifier():
		return
	_upload_score(floor(state_hook.handle.points), input)
	score_upload_form.visible = false

func _on_cancel_submit_score_button_up():
	score_upload_form.visible = false

func _on_state_hook_updated():
	game_over_buttons.visible = state_hook.handle.is_game_over
	conversion_timer_label.text = "" if state_hook.handle.conversion_time_remaining == 0 else "CONVERSION: " + str(state_hook.handle.conversion_time_remaining)

func _on_leaderboard_post_request_completed(result, response_code, headers, body):
	pass

func _on_leaderboard_fetch_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var entries = json["data"]
	var result_str: String = ""
	if json["pageSize"] == 0:
		result_str = "nobody's here, be the first!"
	for i in range(json["pageSize"]):
		var entry = entries[i]
		result_str += str(i+1) + ". " + str(entry["name"]) + " - " + str(entry["score"]) + "\n"
	leaderboard_label.text = result_str

func _on_quit_to_main_menu_button_button_up():
	quit_to_main_menu.emit()
