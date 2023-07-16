extends Node2D
class_name Presentation

@export var tile_size: int
@export var snake_segment_scene: PackedScene

@onready var state_hook: StateHook = $StateHook as StateHook
@onready var scheduler_hook: SchedulerHook = $SchedulerHook as SchedulerHook

# this is an object pool, not a state cache
var active_segments: Array[SnakeSegment] = []
var snake_head: SnakeSegment

func _ready():
	$BoardCanvas.configure(tile_size)
	snake_head = snake_segment_scene.instantiate() as SnakeSegment
	snake_head.setType(SnakeSegment.SegmentType.Head)
	add_child(snake_head)

func _process(delta):
	$Camera2D.position = snake_head.position

func _on_state_hook_updated():
	var num_missing_segments = max(0, state_hook.handle.snake_state.tail.size() - active_segments.size())
	for missing_segment in range(num_missing_segments):
		var new_segment = snake_segment_scene.instantiate() as SnakeSegment
		new_segment.setType(SnakeSegment.SegmentType.Tail)
		add_child(new_segment)
		var previous_segment: SnakeSegment = active_segments.back()
		if previous_segment != null:
			previous_segment.setType(SnakeSegment.SegmentType.Mid)
		new_segment.position = state_hook.handle.snake_state.tail[active_segments.size() + missing_segment] * tile_size
		active_segments.push_back(new_segment) 
	
	var move_tween = create_tween().set_parallel()
	move_tween.tween_property(snake_head, "position", Vector2(state_hook.handle.snake_state.head * tile_size), scheduler_hook.time_to_next_tick()/2.0)
	snake_head.rotation = _rotation_for_heading(state_hook.handle.snake_heading)
	for i in range(state_hook.handle.snake_state.tail.size()):
		active_segments[i].visible = true
		move_tween.tween_property(active_segments[i], "position", Vector2(state_hook.handle.snake_state.tail[i] * tile_size), scheduler_hook.time_to_next_tick()/2.0)
		if i == 0:
			active_segments[i].rotation = _rotation_for_heading((active_segments[i].position - snake_head.position).sign())
		else:
			active_segments[i].rotation = _rotation_for_heading((active_segments[i].position - active_segments[i-1].position).sign())
	
	
	
	if "hit" in state_hook.handle.flags:
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
