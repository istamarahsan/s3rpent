extends Node

signal left_pressed()
signal right_pressed()

func _input(event):
	if event.is_action_pressed("ui_left"):
		left_pressed.emit()
	if event.is_action_pressed("ui_right"):
		right_pressed.emit()
