extends Control
class_name MainMenu

signal play
signal settings
signal leaderboard
signal quit

func _on_start_button_up():
	play.emit()

func _on_settings_button_up():
	settings.emit()

func _on_leaderboard_button_up():
	leaderboard.emit()

func _on_quit_button_up():
	quit.emit()
