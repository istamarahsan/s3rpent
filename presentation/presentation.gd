extends Node2D
class_name Presentation

@export var tile_size: int
@export var snake_segment_scene: PackedScene

@onready var state_hook: StateHook = $StateHook as StateHook

# this is an object pool, not a state cache
var active_segments: Array[SnakeSegment] = []
var snake_head: SnakeSegment

func _ready():
	$BoardCanvas.configure(tile_size)
	snake_head = snake_segment_scene.instantiate() as SnakeSegment
	snake_head.setType(SnakeSegment.SegmentType.Head)
	add_child(snake_head)

func _on_state_hook_updated():
	snake_head.position = state_hook.handle.snake_state.head * tile_size
	snake_head.rotation = _rotation_for_heading(state_hook.handle.snake_heading)
	$Camera2D.position = snake_head.position
	var num_missing_segments = max(0, state_hook.handle.snake_state.tail.size() - active_segments.size())
	for missing_segment in range(num_missing_segments):
		var new_segment = snake_segment_scene.instantiate() as SnakeSegment
		new_segment.setType(SnakeSegment.SegmentType.Tail)
		add_child(new_segment)
		var previous_segment: SnakeSegment = active_segments.back()
		if previous_segment != null:
			previous_segment.setType(SnakeSegment.SegmentType.Mid)
		active_segments.push_back(new_segment) 
	for segment in active_segments:
		segment.visible = false
	for i in range(state_hook.handle.snake_state.tail.size()):
		active_segments[i].visible = true
		active_segments[i].position = state_hook.handle.snake_state.tail[i] * tile_size
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
