extends Control
class_name Gameover

signal replay
signal quit_to_main_menu
signal quit_to_leaderboard

@export var name_field: LineEdit
@export var result_label: Label
@export var submit_button: Button
@export var to_leaderboard_button: Button

@onready var state_hook: StateHook = $StateHook as StateHook

const valid_name_str: String = ""
var awaiting_request: bool = false

func _on_play_again_button_up():
	replay.emit()

func _on_main_menu_button_up():
	quit_to_main_menu.emit()

func _on_upload_score_button_up():
	$UploadScore.visible = true

func _on_submit_button_up():
	submit_button.visible = false
	if state_hook.handle != null:
		$ScorePOST.post(name_field.text, floorf(state_hook.handle.points))

func _validate_name(str: String) -> String:
	return valid_name_str

func _on_score_post_completed(success, message):
	if success:
		to_leaderboard_button.visible = true
		result_label.text = message
	else: 
		submit_button.visible = true
		result_label.text = "! " + message

func _on_to_leaderboard_button_up():
	quit_to_leaderboard.emit()

var prev_text: String = ""
var valid_chars: Array[String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
func _on_line_edit_text_changed(new_text):
	var will_be_empty: bool = new_text == ""
	if will_be_empty:
		prev_text = ""
		submit_button.visible = false
		return
		
	var new_text_is_valid: bool = packed_str_all(new_text.split(), func(char): return char in valid_chars)
	match new_text_is_valid:
		true:
			prev_text = new_text
			submit_button.visible = true
		false:
			name_field.text = prev_text
			name_field.caret_column = prev_text.length()
	
func packed_str_all(arr: PackedStringArray, f: Callable):
	for x in arr:
		if not f.call(x):
			return false
	return true
