extends Node2D
class_name Game

enum InputDirection {
	Right,
	Up,
	Left,
	Down
}

var input_lookup = {
	[InputDirection.Left, Vector2i.UP] : CybersnakeGame.TurnDirection.Left,
	[InputDirection.Right, Vector2i.UP] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Left, Vector2i.DOWN] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Right, Vector2i.DOWN] : CybersnakeGame.TurnDirection.Left,
	[InputDirection.Up, Vector2i.RIGHT] : CybersnakeGame.TurnDirection.Left,
	[InputDirection.Down, Vector2i.RIGHT] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Up, Vector2i.LEFT] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Down, Vector2i.LEFT] : CybersnakeGame.TurnDirection.Left
}

signal quit_to_main_menu

@export var inner_game_scene: PackedScene

@onready var presentation: Presentation = $Presentation as Presentation

var inner_game: CybersnakeGame
var state_hooks: Array[StateHook] = []
var is_action_cooldown: bool = false

func _ready():
	_recreate_game()

func _recreate_game():
	if inner_game != null:
		inner_game.queue_free()
	inner_game = inner_game_scene.instantiate() as CybersnakeGame
	add_child(inner_game)
	_connect_hooks(inner_game)

func _connect_hooks(game: CybersnakeGame):
	state_hooks.clear()
	for child in TreeExtensions.get_tree_rec(self):
		if not child is StateHook:
			continue
		var hook = child as StateHook
		hook.handle = game as GameStateHandle
		state_hooks.push_back(hook)
	for hook in state_hooks:
		hook.initialized.emit()
		hook.updated.emit()

func _handle_direction_input(dir: InputDirection):
	if is_action_cooldown:
		return
	var translated = input_lookup.get([dir, inner_game.snake_heading], null)
	if translated != null and translated is CybersnakeGame.TurnDirection:
		is_action_cooldown = true
		inner_game.action_turn(translated)
		_propagate_hook_signal()

func _propagate_hook_signal():
	for hook in state_hooks:
		hook.updated.emit()

func _on_turn_input_left_pressed():
	_handle_direction_input(InputDirection.Left)
	
func _on_turn_input_right_pressed():
	_handle_direction_input(InputDirection.Right)

func _on_timer_timeout():
	inner_game.process_timestep()
	is_action_cooldown = false
	_propagate_hook_signal()

func _on_demo_ui_request_replay():
	_recreate_game()

func _on_turn_input_up_pressed():
	_handle_direction_input(InputDirection.Up)

func _on_turn_input_down_pressed():
	_handle_direction_input(InputDirection.Down)

func _on_demo_ui_quit_to_main_menu():
	quit_to_main_menu.emit()