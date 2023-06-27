extends Node
class_name GameStateHandle

@export var max_foods: int
@export var world_span: int
@export var snake_mode_interval: int
@export var max_lives: int
var snake_heading: Vector2i
var food_eaten_so_far: int
var snake_state: SnakePositionState
var food_states: Array[FoodState]
var snake_mode: CybersnakeGame.Polarity
var ticks_to_snake_mode_transition: int
var is_game_over: bool
var lives_left: int
