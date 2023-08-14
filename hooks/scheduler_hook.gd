extends Node
class_name SchedulerHook

var _game_timer: Timer
var _transition_timer: Timer
var _conversion_timer: Timer

var _scheduler: Game

signal sprint_activated
signal sprint_deactivated

func tick_time() -> float:
	return _game_timer.wait_time

func time_to_next_tick() -> float:
	return _game_timer.time_left if _game_timer != null and not _game_timer.is_stopped() else 0.0

func time_elapsed() -> float:
	return _scheduler.game_time_elapsed if _scheduler else 0

func sprint_seconds_remaining() -> float:
	return _scheduler.sprint_seconds_remaining if _scheduler else 0
	
func sprint_seconds_fraction() -> float:
	return _scheduler.sprint_seconds_remaining / _scheduler.sprint_capacity_seconds if _scheduler else 0

func can_sprint() -> float:
	return _scheduler.can_sprint() if _scheduler else false

func is_sprinting() -> bool:
	return _scheduler.is_sprint_active if _scheduler else false

func time_to_next_transition() -> float:
	return 0.0 if _transition_timer == null else _transition_timer.wait_time if _transition_timer.is_stopped() else _transition_timer.time_left

func time_conversion_remaining() -> float:
	return 0.0 if _conversion_timer == null else _conversion_timer.wait_time if _conversion_timer.is_stopped() else _conversion_timer.time_left
