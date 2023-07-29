extends Node
class_name SchedulerHook

var _game_timer: Timer
var _transition_timer: Timer
var _conversion_timer: Timer
var _time_elapsed: float = 0

func tick_time() -> float:
	return _game_timer.wait_time

func time_to_next_tick() -> float:
	return _game_timer.time_left if _game_timer != null and not _game_timer.is_stopped() else 0.0

func time_elapsed() -> float:
	return _time_elapsed
	
func time_to_next_transition() -> float:
	return _transition_timer.time_left if _transition_timer != null and not _transition_timer.is_stopped() else 0.0

func time_conversion_remaining() -> float:
	return _conversion_timer.time_left if _conversion_timer != null and not _conversion_timer.is_stopped() else 0.0
