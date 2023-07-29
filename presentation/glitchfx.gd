extends ColorRect

@export_range(0.1, 2, 0.01) var glitch_time: float = 0.5
@export_range(0.1, 1, 0.01) var shake_power: float = 0.03

@onready var state_hook: StateHook = $StateHook as StateHook

func _ready():
	material.set_shader_parameter("shake_power", 0)
	material.set_shader_parameter("shake_rate", 0)

var _glitching: bool = false

func _on_state_hook_updated():
	if not _glitching and state_hook.handle.flags.any(func(flag): return flag.begins_with("hit")):
		_glitching = true
		await _glitch()
		_glitching = false

func _glitch():
	material.set_shader_parameter("shake_power", 0)
	material.set_shader_parameter("shake_rate", 1)
	
	var max_tween = get_tree().create_tween()
	max_tween.tween_method(
		func(degree):
			material.set_shader_parameter("shake_power", degree),
		0.0,
		shake_power,
		glitch_time/3.0
	)
	await max_tween.finished
	
	var min_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	min_tween.tween_method(
		func(degree):
			material.set_shader_parameter("shake_power", degree),
		shake_power,
		0.0,
		glitch_time/3.0 * 2.0
	)
	await min_tween.finished
	material.set_shader_parameter("shake_rate", 0)
