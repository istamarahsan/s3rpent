extends Node2D

@onready var state_hook: StateHook = $StateHook

var food_positions: Dictionary = {}
var tile_size: int = 0

func configure(tile_size: int):
	self.tile_size = tile_size
	queue_redraw()
	
func _draw():
	for y in range(-state_hook.handle.world_span, state_hook.handle.world_span+1):
		for x in range(-state_hook.handle.world_span, state_hook.handle.world_span+1):
			var position := Vector2i(x, y)
			var color := _choose_color(position)
			draw_circle(Vector2(position) * tile_size, 10, color)

func _choose_color(position: Vector2i) -> Color:
	if food_positions.has(position):
		return "#32A433"
	return "#FFFFFF"

func _on_state_hook_updated():
	food_positions = {}
	for food_state in state_hook.handle.food_states:
		if not food_state.is_eaten:
			food_positions[food_state.position] = true
	queue_redraw()
