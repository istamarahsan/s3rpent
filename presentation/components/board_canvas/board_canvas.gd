extends Node2D

@onready var state_hook: StateHook = $StateHook

var food_states_cache_by_position: Dictionary = {}
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
	var food_state = food_states_cache_by_position.get(position)
	if food_state == null or food_state.is_eaten:
		return "#FFFFFF"
	match food_state.polarity:
		CybersnakeGame.Polarity.Organic:
			return "green"
		CybersnakeGame.Polarity.Plastic:
			return "black"
		CybersnakeGame.Polarity.Plastic:
			return "blue"
		_:
			return "red"

func _on_state_hook_updated():
	food_states_cache_by_position.clear()
	for food_state in state_hook.handle.food_states:
		food_states_cache_by_position[food_state.position] = food_state
	queue_redraw()
