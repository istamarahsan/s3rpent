extends Control

signal back_to_game
signal retry
signal main_menu

func _on_back_to_game_button_up():
	back_to_game.emit()

func _on_retry_button_up():
	retry.emit()

func _on_volume_button_up():
	pass # Replace with function body.

func _on_main_menu_button_up():
	main_menu.emit()
