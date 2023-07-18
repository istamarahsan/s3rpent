extends Node2D
class_name Presentation

@export var tile_size: int
@export var snake_segment_scene: PackedScene

@onready var state_hook: StateHook = $StateHook as StateHook
@onready var scheduler_hook: SchedulerHook = $SchedulerHook as SchedulerHook

var active_segments: Array[SnakeSegment] = []
var snake_head: SnakeSegment

func _ready():
	$World.position = Vector2(tile_size/2, tile_size/2)
	$BoardCanvas.configure(tile_size)
	snake_head = snake_segment_scene.instantiate() as SnakeSegment
	snake_head.setType(SnakeSegment.SegmentType.Head)
	add_child(snake_head)

func _process(_delta):
	$Camera2D.position = snake_head.position

func _on_state_hook_updated():
	if active_segments.size() < state_hook.handle.snake_state.tail.size():
		_add_missing_segments()
		_set_segment_types()
	elif active_segments.size() > state_hook.handle.snake_state.tail.size():
		_remove_extra_segments()
		_set_segment_types()
	
	_animate_movement()
	_set_segment_types()
	
	if "hit" in state_hook.handle.flags:
		_animate_hit()

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

func _animate_movement():
	var move_tween = create_tween().set_parallel()
	move_tween.tween_property(snake_head, "position", Vector2(state_hook.handle.snake_state.head * tile_size), scheduler_hook.time_to_next_tick()/1.5)
	snake_head.rotation = _rotation_for_heading(state_hook.handle.snake_heading)
	for i in range(state_hook.handle.snake_state.tail.size()):
		active_segments[i].visible = true
		move_tween.tween_property(active_segments[i], "position", Vector2(state_hook.handle.snake_state.tail[i] * tile_size), scheduler_hook.time_to_next_tick()/1.5)
		if i == 0:
			active_segments[i].rotation = _rotation_for_heading((state_hook.handle.snake_state.head - state_hook.handle.snake_state.tail[i]).sign())
		else:
			active_segments[i].rotation = _rotation_for_heading((state_hook.handle.snake_state.tail[i-1] - state_hook.handle.snake_state.tail[i]).sign())
	await move_tween.finished

func _animate_hit():
	snake_head.flash_hit()
	for segment in active_segments:
		segment.flash_hit()

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
