extends Node2D
class_name Presentation

@export var tile_size: int
@export var snake_segment_scene: PackedScene

@onready var state_hook: StateHook = $StateHook as StateHook

var active_segments: Array[Node] = []

func _ready():
	$BoardCanvas.configure(tile_size)

func _on_state_hook_updated():
	$SnakeSegmentHead.position = state_hook.handle.snake_state.head * tile_size
	$SnakeSegmentHead.rotation = _rotation_for_heading(state_hook.handle.snake_heading)
	$Camera2D.position = $SnakeSegmentHead.position
	$Camera2D.rotation = $SnakeSegmentHead.rotation
	var num_missing_segments = state_hook.handle.snake_state.tail.size() - active_segments.size()
	for missing_segment in range(max(0, num_missing_segments)):
		var segment = snake_segment_scene.instantiate()
		add_child(segment)
		active_segments.push_back(segment) 
	for i in range(state_hook.handle.snake_state.tail.size()):
		active_segments[i].position = state_hook.handle.snake_state.tail[i] * tile_size

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
