extends Node
class_name GameStateHandle

@export var config: GameConfig
var snake_heading: Vector2i
var food_eaten_so_far: int
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
var conversion_time_remaining: int
var world_span: int
