extends Node2D
class_name Game

enum InputDirection {
	Right,
	Up,
	Left,
	Down
}

enum State {
	Playing,
	Paused,
	Stopped
}

var input_lookup = {
	[InputDirection.Left , Vector2i.UP   ] : CybersnakeGame.TurnDirection.Left,
	[InputDirection.Right, Vector2i.UP   ] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Left , Vector2i.DOWN ] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Right, Vector2i.DOWN ] : CybersnakeGame.TurnDirection.Left,
	[InputDirection.Up   , Vector2i.RIGHT] : CybersnakeGame.TurnDirection.Left,
	[InputDirection.Down , Vector2i.RIGHT] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Up   , Vector2i.LEFT ] : CybersnakeGame.TurnDirection.Right,
	[InputDirection.Down , Vector2i.LEFT ] : CybersnakeGame.TurnDirection.Left
}

var parallel_lookup = {
	[InputDirection.Up ,  Vector2i.UP   ] : true,
	[InputDirection.Down, Vector2i.DOWN] : true,
	[InputDirection.Right, Vector2i.RIGHT] : true,
	[InputDirection.Left, Vector2i.LEFT] : true
}

signal quit_to_main_menu
signal quit_to_leaderboard

@export_range(0.1, 3, 0.1) var tick_time: float = 0.5
@export_range(1, 3, 0.1) var sprint_timescale: float = 2.0
@export_range(0.1, 5, 0.1) var sprint_capacity_seconds: float = 3.0
@export_range(0, 1, 0.01) var minimum_sprint: float = 0.3

@onready var presentation: Presentation = $Presentation as Presentation
@onready var inner_game: CybersnakeGame = $CybersnakeGame as CybersnakeGame
@onready var tick_timer: Timer = $TickTimer as Timer
@onready var transition_timer: Timer = $TransitionTimer as Timer
@onready var conversion_timer: Timer = $ConversionTimer as Timer

@onready var sprint_seconds_remaining: float = sprint_capacity_seconds
var state_hooks: Array[StateHook] = []
var scheduler_hooks: Array[SchedulerHook] = []
var is_action_cooldown: bool = false
var is_sprint_active: bool = false
var game_time_elapsed: float = 0
var state: State

func _ready():
	_connect_hooks(inner_game)
	$GameoverLayer.visible = false
	$PauseMenuLayer.visible = false
	for hook in state_hooks:
		hook.initialized.emit()
		hook.updated.emit()
	$StartGameDelayTimer.start()

func _process(delta):
	match state:
		State.Playing:
			game_time_elapsed += delta
			
			var ran_out_of_sprint: bool = false
			if is_sprint_active:
				sprint_seconds_remaining = max(0.0, sprint_seconds_remaining - delta)
				if sprint_seconds_remaining == 0.0:
					is_sprint_active = false
					ran_out_of_sprint = true
					tick_timer.wait_time = _calc_tick_interval()
			else:
				sprint_seconds_remaining = min(sprint_capacity_seconds, sprint_seconds_remaining + delta)
				
			for hook in scheduler_hooks:
				if ran_out_of_sprint:
					hook.sprint_deactivated.emit()

func _input(event):
	match state:
		State.Playing:
			if event.is_action_pressed("ui_cancel"):
				state = State.Paused
				tick_timer.stop()
				transition_timer.paused = true
				conversion_timer.paused = true
				$PauseMenuLayer.visible = true
		State.Paused:
			if event.is_action_pressed("ui_cancel"):
				state = State.Playing
				tick_timer.start()
				transition_timer.paused = false
				conversion_timer.paused = false
				$PauseMenuLayer.visible = false

func can_sprint() -> bool:
	return sprint_seconds_remaining >= sprint_capacity_seconds * minimum_sprint

func _restart_scheduler():
	is_action_cooldown = false
	is_sprint_active = false
	tick_timer.wait_time = _calc_tick_interval()
	game_time_elapsed = 0
	sprint_seconds_remaining = sprint_capacity_seconds
	tick_timer.stop()
	transition_timer.stop()
	conversion_timer.stop()
	tick_timer.paused = false
	transition_timer.paused = false
	conversion_timer.paused = false
	tick_timer.start()
	transition_timer.start()

func _connect_hooks(game: CybersnakeGame):
	state_hooks.clear()
	for child in TreeExtensions.get_tree_rec(self):
		if child is StateHook:
			var hook = child as StateHook
			hook.handle = game as GameStateHandle
			state_hooks.push_back(hook)
		if child is SchedulerHook:
			var hook = child as SchedulerHook
			hook._game_timer = tick_timer
			hook._transition_timer = transition_timer
			hook._conversion_timer = conversion_timer
			hook._scheduler = self
			scheduler_hooks.push_back(hook)

func _handle_direction_input(dir: InputDirection):
	match state:
		State.Playing:
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

func _on_timer_timeout():
	inner_game.process_timestep()
	is_action_cooldown = false
	_propagate_hook_signal()

func _on_transition_timer_timeout():
	inner_game.action_transition()
	_propagate_hook_signal()

func _on_turn_input_left_pressed():
	_handle_direction_input(InputDirection.Left)
	
func _on_turn_input_right_pressed():
	_handle_direction_input(InputDirection.Right)

func _on_turn_input_up_pressed():
	_handle_direction_input(InputDirection.Up)

func _on_turn_input_down_pressed():
	_handle_direction_input(InputDirection.Down)

func _on_sprint_input_sprint_pressed():
	match is_sprint_active:
#		true:
#			is_sprint_active = false
#			for hook in scheduler_hooks:
#				hook.sprint_deactivated.emit()
#			tick_timer.wait_time = _calc_tick_interval()
		false:
			if not can_sprint():
				return
			is_sprint_active = true
			for hook in scheduler_hooks:
				hook.sprint_activated.emit()
			tick_timer.wait_time = _calc_tick_interval()

func _on_state_hook_updated():
	tick_timer.wait_time = _calc_tick_interval()
	if $StateHook.handle.is_game_over:
		tick_timer.paused = true
		transition_timer.paused = true
		conversion_timer.paused = true
		state = State.Stopped
		$GameoverLayer.visible = true
		return
	if "powerup:conversion" in $StateHook.handle.flags:
		transition_timer.paused = true
		conversion_timer.stop()
		conversion_timer.start()
	if "conversion:end" in $StateHook.handle.flags:
		transition_timer.paused = false

func _on_hud_toggle_pause():
	match state:
		State.Playing:
			state = State.Paused
			tick_timer.stop()
			transition_timer.paused = true
			conversion_timer.paused = true
			$PauseMenuLayer.visible = true

func _on_conversion_timer_timeout():
	inner_game.action_deactivate_conversion()
	_propagate_hook_signal()

func _on_gameover_quit_to_main_menu():
	quit_to_main_menu.emit()

func _on_gameover_replay():
	inner_game.reset()
	for hook in state_hooks:
		hook.initialized.emit()
		hook.updated.emit()
	_restart_scheduler()
	state = State.Playing
	$GameoverLayer.visible = false

func _on_start_game_delay_timer_timeout():
	_restart_scheduler()
	state = State.Playing

func _on_pause_menu_back_to_game():
	match state:
		State.Paused:
			state = State.Playing
			tick_timer.start()
			transition_timer.paused = false
			conversion_timer.paused = false
			$PauseMenuLayer.visible = false

func _on_pause_menu_main_menu():
	match state:
		State.Paused:
			quit_to_main_menu.emit()

func _on_pause_menu_retry():
	match state:
		State.Paused:
			state = State.Playing
			inner_game.reset()
			for hook in state_hooks:
				hook.initialized.emit()
				hook.updated.emit()
			_restart_scheduler()
			$PauseMenuLayer.visible = false

var zoomed: bool = false
func _on_hud_debug_toggle_camera():
	$Presentation/Camera2D.zoom = Vector2(0.8, 0.8) if zoomed else Vector2(0.1, 0.1)
	zoomed = not zoomed

func _on_gameover_quit_to_leaderboard():
	quit_to_leaderboard.emit()

const TIMER_MIN_TIME: float = 0.05
func _calc_tick_interval() -> float:
	var result: float 
	result = tick_time / inner_game.active_point_multiplier
	result = result / sprint_timescale if is_sprint_active else result
	result = maxf(TIMER_MIN_TIME, result)
	return result
