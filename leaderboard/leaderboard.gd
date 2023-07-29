extends Control
class_name Leaderboard

signal back

func _on_button_button_up():
	back.emit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back.emit()
