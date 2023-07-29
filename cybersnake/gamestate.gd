extends Node
class_name GameStateHandle

@export var config: GameConfig
var snake_heading: Vector2i
var food_eaten_so_far_cat: Dictionary
var food_eaten_so_far: int:
	get:
		return food_eaten_so_far_cat.values().reduce(func(sum, next): return sum + next, 0)
	set(value):
		return
var snake_state: SnakePositionState
var food_states: Array[FoodState]
var snake_mode: CybersnakeGame.Polarity
var ticks_to_snake_mode_transition: int
var is_game_over: bool
var max_lives: int
var lives_left: int
var points: float
var active_point_multiplier: float
var flags: Array[String]
var powerup_states: Array[PowerupState]
var is_conversion_active: bool
var world_span: int
