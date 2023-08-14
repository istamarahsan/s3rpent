extends Control
class_name Leaderboard

enum State {
	Loading,
	Done,
	Error
}

signal back

@export var loading: Control
@onready var leaderboardEntries: LeaderboardEntries = $Entries as LeaderboardEntries
@onready var genericErrorPanel: Control = $Error as Control

var state: State = State.Loading

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back.emit()

func _ready():
	genericErrorPanel.visible = false
	reload()

func reload():
	var ok = $FetchScores.fetch()
	if not ok:
		state = State.Error
		loading.visible = false
		genericErrorPanel.visible = true

func _on_back_button_up():
	back.emit()

func _on_fetch_scores_request_completed(result, response_code, headers, body):
	match state:
		State.Loading:
			if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
				state = State.Error
				loading.visible = false
				genericErrorPanel.visible = true
				return
			
			state = State.Done
			
			loading.visible = false
			
			var data := _parse_response_data(body)
			data.sort_custom(func(a, b): return a.score > b.score)
			leaderboardEntries.bind(data)
			leaderboardEntries.animate_show()

func _on_retry_load_button_up():
	match state:
		State.Error:
			state = State.Loading
			loading.visible = true
			genericErrorPanel.visible = false
			reload()

func _parse_response_data(body) -> Array[LeaderboardEntry.LeaderboardEntryData]:
	var json = JSON.parse_string(body.get_string_from_utf8())
	var entries = json["data"]
	var result: Array[LeaderboardEntry.LeaderboardEntryData] = []
	for entry in entries:
		result.push_back(LeaderboardEntry.LeaderboardEntryData.new(entry["name"], int(entry["score"])))
	return result
