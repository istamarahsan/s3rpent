extends Control
@onready var resoption=$Container2/ResSize/OptionButton
var resolution: Dictionary={"1920x1080":Vector2i(1920,1080),
							"1600x900":Vector2i(1600,900),
							"1280x720":Vector2i(1280,720)
							
							
							}

# Called when the node enters the scene tree for the first time.
func _ready():
	AddResolutions()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func AddResolutions():
	for i in resolution:
		resoption.add_item(i)


func _process(delta):
	pass


func _on_option_button_item_selected(index):
	var size=resolution.get(resoption.get_item_text(index))
	get_window().size=size
	get_tree().root.CONTENT_SCALE_MODE_DISABLED
	#DisplayServer.window_set_position()
	pass # Replace with function body.


func _on_backtomain_pressed():
	get_tree().change_scene_to_file("res://Mainmenu.tscn")
	pass # Replace with function body.


func _on_check_button_toggled(button_pressed):
	if(button_pressed==true):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.
