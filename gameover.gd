extends Control
class_name Gameover

signal replay
signal quit_to_main_menu
signal quit_to_leaderboard

@export var name_field: LineEdit
@export var error_label: Label
@export var result_label: Label
@export var submit_button: Button
@export var to_leaderboard_button: Button

@onready var state_hook: StateHook = $StateHook as StateHook

const valid_name_str: String = ""
var awaiting_request: bool = false

func _ready():
	name_field.text_changed.connect(_on_name_field_text_changed)

func _on_name_field_text_changed(new: String):
	var validation := _validate_name(new)
	
	if validation != valid_name_str:
		error_label.text = validation
		submit_button.disabled = true
		return
	
	error_label.text = ""
	submit_button.disabled = false

func _on_play_again_button_up():
	replay.emit()

func _on_main_menu_button_up():
	quit_to_main_menu.emit()

func _on_upload_score_button_up():
	$UploadScore.visible = true

func _on_submit_button_up():
	submit_button.visible = false
	if state_hook.handle != null:
		$ScorePOST.post(name_field.text, state_hook.handle.points)

func _validate_name(str: String) -> String:
	return valid_name_str

func _on_score_post_completed(success):
	if success:
		result_label.text = "Score uploaded!"
		to_leaderboard_button.visible = true
	else: 
		result_label.text = "Unable to upload."
		submit_button.visible = true

func _on_to_leaderboard_button_up():
	quit_to_leaderboard.emit()
