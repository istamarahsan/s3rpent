extends Node2D

@export var tile_size: int = 0

@onready var state_hook: StateHook = $StateHook as StateHook
@onready var lines: Array[Line2D] = [
	$Line1 as Line2D,
	$Line2 as Line2D,
	$Line3 as Line2D
]

var food_positions: Array[Vector2i] = []

func _ready():
	for line in lines:
		line.visible = false
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2.ZERO)

func _process(delta):
	for line in lines:
		line.visible = false
	for i in range(lines.size()):
		if i >= food_positions.size():
			continue
		lines[i].visible = true
		lines[i].set_point_position(1, (Vector2(food_positions[i]) - Vector2(state_hook.handle.snake_state.head)).normalized().rotated(-get_parent().rotation) * tile_size)

func _on_state_hook_updated():
	food_positions = []
	for food_state in state_hook.handle.food_states:
		if food_state.is_eaten:
			continue
		food_positions.push_back(food_state.position)
