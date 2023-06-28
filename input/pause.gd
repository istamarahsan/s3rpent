extends Control


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event.is_action_pressed("pause"):
		var ispaused=not get_tree().paused
		get_tree().paused=not get_tree().paused
		visible=ispaused
