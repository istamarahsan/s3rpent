extends Node2D
class_name Presentation

@export var tile_size: int
@export var snake_segment_scene: PackedScene

@onready var state_hook: StateHook = $StateHook as StateHook
@onready var scheduler_hook: SchedulerHook = $SchedulerHook as SchedulerHook

var active_segments: Array[SnakeSegment] = []
var snake_head: SnakeSegment

var countdown_threshold: float = 3
var prev_time_to_transition: float = 0

func _ready():
	$DebugCanvas.configure(tile_size)
	snake_head = snake_segment_scene.instantiate() as SnakeSegment
	snake_head.setType(SnakeSegment.SegmentType.Head)
	add_child(snake_head)
	prev_time_to_transition = scheduler_hook.time_to_next_transition()

func _process(_delta):
	$Camera2D.position = snake_head.position
	var t = scheduler_hook.time_to_next_transition()
	if t < float(countdown_threshold + 1) and int(t) < int(prev_time_to_transition):
		$Countdown.play()
	prev_time_to_transition = t

func _on_state_hook_initialized():
	snake_head.rotation = _rotation_for_heading(state_hook.handle.snake_heading)

func _on_state_hook_updated():
	if active_segments.size() < state_hook.handle.snake_state.tail.size():
		_add_missing_segments()
		_set_segment_types()
		_set_segment_polarities()
	elif active_segments.size() > state_hook.handle.snake_state.tail.size():
		_remove_extra_segments()
		_set_segment_types()
		_set_segment_polarities()
		
	if "moved" in state_hook.handle.flags:
		snake_head.rotation = _rotation_for_heading(state_hook.handle.snake_heading)
		$Move.play()
	
	_animate_movement()
	_set_segment_types()
	
	if state_hook.handle.flags.any(func(flag): return flag.begins_with("hit")):
		_animate_hit()
		if "hit:wall" in state_hook.handle.flags:
			$WallHit.play()
		else:
			$Hit.play()
		
	if "ate" in state_hook.handle.flags:
		$Eat.play()
		
	if state_hook.handle.flags.any(func(flag): return flag.begins_with("powerup")):
		$PowerUp.play()
	
	if "transition" in state_hook.handle.flags:
		$Transition.play()
		_set_segment_polarities()
	
	if "gameover" in state_hook.handle.flags:
		$GameOver.play()

func _add_missing_segments():
	var num_missing_segments = max(0, state_hook.handle.snake_state.tail.size() - active_segments.size())
	for missing_segment in range(1, num_missing_segments+1):
		var new_segment = snake_segment_scene.instantiate() as SnakeSegment
		add_child(new_segment)
		var tail_pos = active_segments.size()
		new_segment.position = state_hook.handle.snake_state.tail[tail_pos] * tile_size
		if tail_pos == 0:
			new_segment.rotation = _rotation_for_heading((new_segment.position - snake_head.position).sign())
		else:
			new_segment.rotation = _rotation_for_heading((new_segment.position - active_segments[tail_pos-1].position).sign())
		active_segments.push_back(new_segment) 

func _remove_extra_segments():
	var num_extra_segments = max(0, active_segments.size() - state_hook.handle.snake_state.tail.size())
	for extra_segment in range(num_extra_segments):
		var segment: SnakeSegment = active_segments.pop_back()
		segment.queue_free()

func _set_segment_polarities():
	snake_head.set_polarity(state_hook.handle.snake_mode)
	for segment in active_segments:
		segment.set_polarity(state_hook.handle.snake_mode)

func _set_segment_types():
	if active_segments.size() == 0:
		return
	for i in range(0, state_hook.handle.snake_state.tail.size()-1):
		var in_vec = Vector2((state_hook.handle.snake_state.tail[i] - state_hook.handle.snake_state.head).sign() if i == 0 else (state_hook.handle.snake_state.tail[i] - state_hook.handle.snake_state.tail[i-1]).sign())
		var out_vec = Vector2((state_hook.handle.snake_state.tail[i+1] - state_hook.handle.snake_state.tail[i]).sign())
		var cross = in_vec.cross(out_vec)
		if cross == 0:
			active_segments[i].setType(SnakeSegment.SegmentType.Body)
		elif cross < 0:
			active_segments[i].setType(SnakeSegment.SegmentType.CornerLeft)
		elif cross > 0:
			active_segments[i].setType(SnakeSegment.SegmentType.CornerRight)
	active_segments.back().setType(SnakeSegment.SegmentType.Tail)

var move_tween: Tween

func _animate_movement():
	if is_instance_valid(move_tween) and move_tween.is_valid():
		move_tween.kill()
	var time_to_next_tick: float = scheduler_hook.time_to_next_tick()
	move_tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(snake_head, "position", Vector2(state_hook.handle.snake_state.head * tile_size), 0)
	for i in range(state_hook.handle.snake_state.tail.size()):
		active_segments[i].visible = true
		move_tween.tween_property(active_segments[i], "position", Vector2(state_hook.handle.snake_state.tail[i] * tile_size), 0)
		if i == 0:
			active_segments[i].rotation = _rotation_for_heading((state_hook.handle.snake_state.head - state_hook.handle.snake_state.tail[i]).sign())
		else:
			active_segments[i].rotation = _rotation_for_heading((state_hook.handle.snake_state.tail[i-1] - state_hook.handle.snake_state.tail[i]).sign())
	await move_tween.finished

func _animate_hit():
	snake_head.flash_hit()
	for segment in active_segments:
		segment.flash_hit()

func _animate_transition():
	pass

func _rotation_for_heading(heading: Vector2i) -> float:
	match heading:
		Vector2i.UP:
			return deg_to_rad(-90)
		Vector2i.LEFT:
			return deg_to_rad(-180)
		Vector2i.DOWN:
			return deg_to_rad(-270)
		_:
			return 0
