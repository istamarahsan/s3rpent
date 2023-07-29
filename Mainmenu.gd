extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_2_pressed():
	get_tree().change_scene_to_file("res://root.tscn")
	pass # Replace with function body.


func _on_option_pressed():
	get_tree().change_scene_to_file("res://options.tscn")
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
