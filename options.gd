extends Control
@onready var resoption=$Container2/ResSize/OptionButton
var resolution: Dictionary={"1920x1080":Vector2i(1920,1080),
							"1600x900":Vector2i(1600,900)
							
							
							
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
	#var size=resolution.get(resoption.get_item_text(index))
	#get_tree().root.content_scale_mode
	#get_window().size
	if Engine.is_editor_hint:
		var screen_size = DisplayServer.screen_get_size()
		Window.MODE_WINDOWED
		get_window().size=resoption
	pass # Replace with function body.
