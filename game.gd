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

@onready var presentation: Presentation = $Presentation as Presentation
@onready var inner_game: CybersnakeGame = $CybersnakeGame as CybersnakeGame

var state_hooks: Array[StateHook] = []
var scheduler_hooks: Array[SchedulerHook] = []
var is_action_cooldown: bool = false

func _ready():
	_connect_hooks(inner_game)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if $Timer.is_stopped():
			$Timer.start()
		else:
			$Timer.stop() 

func _recreate_game():
	inner_game.reset()

func _connect_hooks(game: CybersnakeGame):
	state_hooks.clear()
	for child in TreeExtensions.get_tree_rec(self):
		if child is StateHook:
			var hook = child as StateHook
			hook.handle = game as GameStateHandle
			state_hooks.push_back(hook)
		if child is SchedulerHook:
			var hook = child as SchedulerHook
			hook._game_timer = $Timer
			scheduler_hooks.push_back(hook)
			
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
