extends Node

enum UpperState {
	MainMenu,
	Playing
}

@export var game_scene: PackedScene
@export var main_menu_scene: PackedScene

@onready var fullscreen_ui_root: Control = $FullscreenUiRoot

var state: UpperState = UpperState.MainMenu

func _ready():
	_create_main_menu()

func _create_main_menu():
	var main_menu = main_menu_scene.instantiate() as MainMenu
	main_menu.play.connect(func(): _on_main_menu_play(main_menu))
	main_menu.quit.connect(func(): _on_main_menu_quit(main_menu))
	fullscreen_ui_root.add_child(main_menu)

func _create_game():
	var game = game_scene.instantiate() as Game
	game.quit_to_main_menu.connect(func(): _on_game_quit_to_main_menu(game))
	add_child(game)

func _on_main_menu_play(main_menu: MainMenu):
	if state != UpperState.MainMenu:
		return
	state = UpperState.Playing
	main_menu.queue_free()
	_create_game()

func _on_main_menu_quit(_main_menu: MainMenu):
	if state != UpperState.MainMenu:
		return
	get_tree().quit()

func _on_game_quit_to_main_menu(game: Game):
	if state != UpperState.Playing:
		return
	state = UpperState.MainMenu
	game.queue_free()
	_create_main_menu()
