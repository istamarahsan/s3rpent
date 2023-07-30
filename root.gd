extends Node

enum UpperState {
	MainMenu,
	Playing,
	Leaderboard,
	Settings
}

@onready var fullscreen_ui_root: Control = $FullscreenUiRoot
@onready var splash_screen: SplashScreen = $FullscreenUiRoot/SplashScreen

const main_menu_scene: PackedScene = preload("res://Mainmenu.tscn")
const game_scene: PackedScene = preload("res://game.tscn")
const leaderboard_scene: PackedScene = preload("res://leaderboard/leaderboard.tscn")

var state: UpperState = UpperState.MainMenu

func _ready():
	_create_main_menu()
	$MainmenuMusic.play()

func _create_main_menu():
	var main_menu = main_menu_scene.instantiate() as MainMenu
	main_menu.play.connect(func(): _on_main_menu_play(main_menu))
	main_menu.leaderboard.connect(func(): _on_main_menu_leaderboard(main_menu))
	main_menu.quit.connect(func(): _on_main_menu_quit(main_menu))
	fullscreen_ui_root.add_child(main_menu)

func _create_game():
	var game = game_scene.instantiate() as Game
	game.quit_to_main_menu.connect(func(): _on_game_quit_to_main_menu(game))
	game.quit_to_leaderboard.connect(func(): _on_game_quit_to_leaderboard(game))
	add_child(game)

func _create_leaderboard():
	var leaderboard = leaderboard_scene.instantiate() as Leaderboard
	leaderboard.back.connect(func(): _on_leaderboard_back(leaderboard))
	add_child(leaderboard)

func _on_main_menu_play(main_menu: MainMenu):
	if state != UpperState.MainMenu:
		return
	state = UpperState.Playing
	_fade_out_music($MainmenuMusic, 1.5)
	_create_game()
	main_menu.queue_free()

func _on_main_menu_quit(_main_menu: MainMenu):
	if state != UpperState.MainMenu:
		return
	get_tree().quit()

func _on_main_menu_leaderboard(main_menu: MainMenu):
	if state != UpperState.MainMenu:
		return
	state = UpperState.Leaderboard
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property($MainmenuMusic, "volume_db", -20, 1.5)
	
	_create_leaderboard()
	main_menu.queue_free()

func _on_leaderboard_back(leaderboard: Leaderboard):
	if state != UpperState.Leaderboard:
		return
	state = UpperState.MainMenu
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property($MainmenuMusic, "volume_db", 0, 1.5)
	
	_create_main_menu()
	leaderboard.queue_free()

func _on_game_quit_to_main_menu(game: Game):
	if state != UpperState.Playing:
		return
	state = UpperState.MainMenu
	$MainmenuMusic.play()
	_create_main_menu()
	game.queue_free()

func _on_game_quit_to_leaderboard(game: Game):
	if state != UpperState.Playing:
		return
	state = UpperState.Leaderboard
	_create_leaderboard()
	game.queue_free()

func _fade_out_music(player: AudioStreamPlayer, seconds: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "volume_db", -80, seconds)
	await tween.finished
	player.stop()
	player.volume_db = 0.0
