extends Control
class_name MainMenu

signal play
signal quit

@onready var play_button: Button = get_node("%Play")
@onready var quit_button: Button = get_node("%Quit")

func _ready():
	play_button.button_up.connect(_on_play_button_pressed)
	quit_button.button_up.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	play.emit()

func _on_quit_button_pressed():
	quit.emit()
