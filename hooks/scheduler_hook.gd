extends Node
class_name SchedulerHook

var _game_timer: Timer
var _time_elapsed: float = 0

func tick_time() -> float:
	return _game_timer.wait_time

func time_to_next_tick() -> float:
	return _game_timer.time_left if _game_timer != null and not _game_timer.is_stopped() else 0

func time_elapsed() -> float:
	return _time_elapsed
