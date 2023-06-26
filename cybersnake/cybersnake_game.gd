extends GameStateHandle
class_name CybersnakeGame

signal state_updated(gamestate, flags)

enum TurnDirection {
	Left,
	Right
}

enum Polarity {
	Organic,
	Paper,
	Plastic
}

func _ready():
	_initialize()

func action_turn(action: TurnDirection):
	snake_heading = _parse_rotate(snake_heading, action)
	state_updated.emit(self, ["heading"])

func process_timestep():
	var state_flags: Dictionary = {}

	var previous_segment_position: Vector2i = snake_state.head
	var new_head_position: Vector2i = snake_state.head + snake_heading
	var would_go_out_of_bounds: bool = new_head_position.abs().x > world_span or new_head_position.abs().y > world_span
	if not would_go_out_of_bounds:
		snake_state.head = new_head_position
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
		
		var next_segment_position: Vector2i = (snake_heading * -1).clamp(Vector2i.ONE * -1, Vector2i.ONE) + snake_state.head if snake_state.tail.size() == 0 else (snake_state.tail[-1] - (snake_state.tail[-2] if snake_state.tail.size() > 1 else snake_state.head)).clamp(Vector2i.ONE * -1, Vector2i.ONE) + snake_state.tail[-1]
		snake_state.tail.push_back(next_segment_position)
		
		state_flags["food_states"] = true
		state_flags["food_eaten_so_far"] = true
		state_flags["snake_state"] = true
	
	ticks_to_snake_mode_transition -= 1
	if ticks_to_snake_mode_transition == 0:
		snake_mode = _next_snake_mode(snake_mode)
		ticks_to_snake_mode_transition = snake_mode_interval
		state_flags["snake_mode"] = true

	state_updated.emit(self, state_flags)

func _initialize():
	ticks_to_snake_mode_transition = snake_mode_interval
	snake_state = SnakePositionState.new()
	snake_state.head = Vector2i.ZERO
	snake_heading = Vector2i.RIGHT
	food_states = []
	for i in range(max_foods):
		var food_state = FoodState.new()
		food_state.position = Vector2i.ZERO
		food_state.is_eaten = false
		food_states.push_back(food_state)
	var food_positions = _random_food_positions(max_foods)
	for i in range(food_positions.size()):
		food_states[i].position = food_positions[i]

func _parse_rotate(vector: Vector2i, rotate_direction: TurnDirection) -> Vector2i:
	return Vector2i(vector.y, vector.x * -1) if rotate_direction == TurnDirection.Left else Vector2i(vector.y * -1, vector.x)

func _random_food_positions(n: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	while result.size() < n:
		var x: int = randi_range(-world_span, world_span)
		var y: int = randi_range(-world_span, world_span)
		var pos = Vector2i(x, y)
		if result.has(pos) or snake_state.head == pos or snake_state.tail.any(func(tail_pos): return tail_pos == pos):
			continue
		else:
			result.push_back(pos)
	return result

func _next_snake_mode(mode: Polarity) -> Polarity:
	match mode:
		Polarity.Organic:
			return Polarity.Paper
		Polarity.Paper:
			return Polarity.Plastic
		Polarity.Plastic:
			return Polarity.Organic
		_:
			return Polarity.Organic

func _top_left() -> Vector2i:
	return Vector2i(-world_span, -world_span)

func _top_right() -> Vector2i:
	return Vector2i(world_span, -world_span)

func _bottom_right() -> Vector2i:
	return Vector2i(world_span, world_span)
	
func _bottom_left() -> Vector2i:
	return Vector2i(-world_span, world_span)
