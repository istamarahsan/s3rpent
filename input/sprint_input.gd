extends Node

signal sprint_pressed

func _input(event):
	if event.is_action_pressed("sprint"):
		sprint_pressed.emit()
