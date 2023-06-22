extends Node
class_name CybersnakeGame

signal state_update(gamestate, flags)

enum TurnDirection {
	Left,
	Right
}

@export var max_foods: int = 3
@export var world_span: int = 5

var snake_heading := Vector2i.RIGHT
var is_act_cooldown: bool = false
var food_eaten_so_far: int = 0
var snake_state: SnakePositionState
var food_states: Array[FoodState] = []

func _ready():
	snake_state = SnakePositionState.new()
	snake_state.head = Vector2i.ZERO

func action_turn(action: TurnDirection):
	if is_act_cooldown:
		return
	is_act_cooldown = true
	snake_heading = _parse_rotate(snake_heading, action)
	state_update.emit(self, ["heading"])

func process_timestep():
	is_act_cooldown = false
	var state_flags: Dictionary = {}

	var previous_segment_position: Vector2i = snake_state.head
	var new_head_position: Vector2i = snake_state.head + snake_heading
	snake_state.head = new_head_position.clamp(
		Vector2i.ONE * -world_span,
		Vector2i.ONE * world_span
	)
	for i_segment in range(snake_state.tail.size()):
		var segment_position = snake_state.tail[i_segment]
		snake_state.tail[i_segment] = previous_segment_position
		previous_segment_position = segment_position
	state_flags["snake_state"] = true

	if food_states.all(func(_state): return _state.is_eaten):
		for food_state in food_states:
			food_state.position = Vector2i.ZERO
			food_state.is_eaten = false
		var new_positions = _random_food_positions(food_states.size())
		for i_food in range(new_positions.size()):
			food_states[i_food].position = new_positions[i_food]
		state_flags["food_states"] = true

	for food_state in food_states:
		if food_state.is_eaten:
			continue
		if food_state.position != snake_state.head:
			continue
		food_state.is_eaten = true
		food_eaten_so_far += 1
		state_flags["food_states"] = true
		state_flags["food_eaten_so_far"] = true

	state_update.emit(self, state_flags.keys())

func _parse_rotate(vector: Vector2i, rotate_direction: TurnDirection) -> Vector2i:
	return Vector2i(vector.y, vector.x * -1) if rotate_direction == TurnDirection.Right else Vector2i(vector.y * -1, vector.x)

func _random_food_positions(n: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	while result.size() < n:
		var x: int = randi_range(-world_span, world_span)
		var y: int = randi_range(-world_span, world_span)
		var pos = Vector2i(x, y)
		if result.has(pos) or snake_state.head == pos or snake_state.tail.any(func(tail_pos): return tail_pos == pos):
			continue
		else:
			result.push_back(pos)
	return result

func _top_left() -> Vector2i:
	return Vector2i(-world_span, -world_span)

func _top_right() -> Vector2i:
	return Vector2i(world_span, -world_span)

func _bottom_right() -> Vector2i:
	return Vector2i(world_span, world_span)
	
func _bottom_left() -> Vector2i:
	return Vector2i(-world_span, world_span)
