extends Node2D

@export_category("Colors")
@export_color_no_alpha var default_color: Color = "white"
@export_color_no_alpha var organic_color: Color = "green"
@export_color_no_alpha var plastic_color: Color = "black"
@export_color_no_alpha var paper_color: Color = "red"
@export_color_no_alpha var extra_life_color: Color = "blue"
@export_color_no_alpha var conversion_color: Color = "gold"

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
	if food_state != null and not food_state.is_eaten:
		return _choose_color_food(food_state)
	var powerup_state = state_hook.handle.powerup_states.filter(func(x): return x.position == position).pop_back()
	if powerup_state != null and not powerup_state.is_eaten:
		return _choose_powerup_color(powerup_state)
	return default_color

func _choose_powerup_color(powerup_state: PowerupState) -> Color:
	match powerup_state.type:
		CybersnakeGame.PowerupType.ExtraLife:
			return extra_life_color
		CybersnakeGame.PowerupType.Conversion:
			return conversion_color
		_:
			return default_color

func _choose_color_food(food_state: FoodState) -> Color:
	match food_state.polarity:
		CybersnakeGame.Polarity.Organic:
			return organic_color
		CybersnakeGame.Polarity.Plastic:
			return plastic_color
		CybersnakeGame.Polarity.Paper:
			return paper_color
		_:
			return default_color

func _on_state_hook_updated():
	food_states_cache_by_position.clear()
	for food_state in state_hook.handle.food_states:
		food_states_cache_by_position[food_state.position] = food_state
	queue_redraw()
