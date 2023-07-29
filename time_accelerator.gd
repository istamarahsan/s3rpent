extends StateHook

@export var timer: Timer
@export_range(0.1, 999, 0.01) var base_pace: float

func _ready():
	timer.one_shot = false
	timer.autostart = false

func _on_initialized():
	timer.wait_time = base_pace

func _on_updated():
	timer.wait_time = base_pace / handle.active_point_multiplier
