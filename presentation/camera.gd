extends Camera2D

@onready var state_hook: StateHook = $StateHook as StateHook

var zoom_tween: Tween = null

func _on_state_hook_initialized():
	_adjust_zoom()

func _on_state_hook_updated():
	if not "multiplier" in state_hook.handle.flags:
		return
	_adjust_zoom()

func _adjust_zoom():
	if is_instance_valid(zoom_tween) and zoom_tween.is_running():
		zoom_tween.stop()
	var zoom_scale = inverse_lerp(
		1, 
		2, 
		clampf(state_hook.handle.active_point_multiplier, 1, 2)
	)
	var zoom_val = lerpf(0.8, 0.4, zoom_scale)
	var actual_zoom = Vector2(zoom_val, zoom_val)
	zoom_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	zoom_tween.tween_property(self, "zoom", actual_zoom, 0.5)
