extends ColorRect

@export_range(0.1, 2, 0.01) var glitch_time: float = 0.5
@export_range(0.01, 1, 0.01) var shake_power_hit: float = 0.03
@export_range(0.01, 1, 0.01) var shake_power_gameover: float = 0.001
@export_range(0.01, 1, 0.01) var shake_color: float = 0.01

@onready var state_hook: StateHook = $StateHook as StateHook

var _glitching: bool = false

func _on_state_hook_initialized():
	_glitching = false
	material.set_shader_parameter("shake_power", 0)
	material.set_shader_parameter("shake_rate", 0)

func _on_state_hook_updated():
	if not _glitching and state_hook.handle.flags.any(func(flag): return flag.begins_with("hit")):
		_glitching = true
		material.set_shader_parameter("shake_power", 0)
		await _glitch_in(glitch_time/3.0, 0.0, shake_power_hit)
		if "gameover" in state_hook.handle.flags:
			await _glitch_in(glitch_time, shake_power_hit, shake_power_gameover)
			return
		await _glitch_out(glitch_time/3.0 * 2.0, shake_power_hit)
		_glitching = false
	elif  "gameover" in state_hook.handle.flags:
		_glitch_in(glitch_time, 0.0, shake_power_gameover)

func _glitch_in(seconds: float, from: float, to: float):
	material.set_shader_parameter("shake_rate", 1)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_method(
		func(degree):
			material.set_shader_parameter("shake_power", degree),
		from,
		to,
		seconds
	)
	tween.tween_method(
		func(degree):
			material.set_shader_parameter("shake_color_rate", degree),
		0.0,
		shake_color,
		seconds/10.0
	)
	await tween.finished

func _glitch_out(seconds: float, from: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_method(
		func(degree):
			material.set_shader_parameter("shake_power", degree),
		from,
		0.0,
		seconds
	)
	tween.tween_method(
		func(degree):
			material.set_shader_parameter("shake_color_rate", degree),
		shake_color,
		0.0,
		seconds/2.0
	)
	await tween.finished
	material.set_shader_parameter("shake_rate", 0)
