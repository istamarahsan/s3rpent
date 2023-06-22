extends RefCounted
class_name GameStateHandle

var snake_heading: Vector2i
var is_act_cooldown: bool
var food_eaten_so_far: int
var snake_state: SnakePositionState
var food_states: Array[FoodState]

func _init(
	_snake_heading: Vector2i, 
	_is_act_cooldown: bool, 
	_food_eaten_so_far: int, 
	_snake_state: SnakePositionState, 
	_food_states: Array[FoodState]):
		snake_heading = _snake_heading
		is_act_cooldown = is_act_cooldown
		food_eaten_so_far = _food_eaten_so_far
		snake_state = _snake_state
		food_states = _food_states
