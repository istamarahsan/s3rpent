extends Node

signal start_sprint
signal stop_sprint

func _input(event):
	if event.is_action_pressed("sprint"):
		start_sprint.emit()
	if event.is_action_released("sprint"):
		stop_sprint.emit()
