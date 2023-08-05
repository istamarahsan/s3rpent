extends Control

signal back_to_game
signal retry
signal main_menu


func _on_back_to_game_button_up():
	back_to_game.emit()

func _on_retry_button_up():
	$ConfirmationDialog.visible = true

func _on_settings_button_up():
	$Settings.visible = true

func _on_main_menu_button_up():
	main_menu.emit()

func _on_settings_back():
	$Settings.visible = false

func _on_confirmation_dialog_confirmed():
	retry.emit()
