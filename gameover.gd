extends Control
class_name Gameover

signal replay
signal quit_to_main_menu

func _on_play_again_button_up():
	replay.emit()

func _on_main_menu_button_up():
	quit_to_main_menu.emit()
