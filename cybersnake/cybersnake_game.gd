extends GameStateHandle
class_name CybersnakeGame

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
	if is_game_over:
		return
	snake_heading = _parse_rotate(snake_heading, action)

func process_timestep():
	if is_game_over:
		return
	
	var previous_segment_position: Vector2i = snake_state.head
	var new_head_position: Vector2i = snake_state.head + snake_heading
	var would_go_out_of_bounds: bool = new_head_position.abs().x > world_span or new_head_position.abs().y > world_span
	var would_collide_with_self: bool = snake_state.tail.any(func(segment_position): return segment_position == new_head_position)
	if would_go_out_of_bounds or would_collide_with_self:
		lives_left -= 1
	else:
		snake_state.head = new_head_position
		for i_segment in range(snake_state.tail.size()):
			var segment_position = snake_state.tail[i_segment]
			snake_state.tail[i_segment] = previous_segment_position
			previous_segment_position = segment_position

	for food_state in food_states:
		if food_state.is_eaten:
			food_state.position = _random_food_position()
			food_state.is_eaten = false
			food_state.polarity = _random_polarity()
			continue
		
		if food_state.position != snake_state.head:
			continue
		
		if food_state.polarity != snake_mode:
			lives_left -= 1
			continue
		
		food_state.is_eaten = true
		food_eaten_so_far += 1
		if food_eaten_so_far % 10 == 0:
			active_point_multiplier += 0.1
		points += 10 * active_point_multiplier
		points = snappedf(points, 0.01)
		var next_segment_position: Vector2i = (snake_heading * -1).clamp(Vector2i.ONE * -1, Vector2i.ONE) + snake_state.head if snake_state.tail.size() == 0 else (snake_state.tail[-1] - (snake_state.tail[-2] if snake_state.tail.size() > 1 else snake_state.head)).clamp(Vector2i.ONE * -1, Vector2i.ONE) + snake_state.tail[-1]
		snake_state.tail.push_back(next_segment_position)
	
	ticks_to_snake_mode_transition -= 1
	if ticks_to_snake_mode_transition <= 0:
		snake_mode = _next_snake_mode(snake_mode)
		ticks_to_snake_mode_transition = snake_mode_interval

	if lives_left <= 0:
		is_game_over = true

func _initialize():
	is_game_over = false
	max_lives = 3
	lives_left = max_lives
	ticks_to_snake_mode_transition = snake_mode_interval
	snake_state = SnakePositionState.new()
	snake_state.head = Vector2i.ZERO
	snake_heading = Vector2i.RIGHT
	food_states = []
	points = 0
	active_point_multiplier = 1
	for i in range(max_foods):
		var food_state = FoodState.new()
		food_state.position = Vector2i.ZERO
		food_state.is_eaten = false
		food_state.polarity = _random_polarity()
		food_states.push_back(food_state)
	var food_positions = _random_food_positions(max_foods)
	for i in range(food_positions.size()):
		food_states[i].position = food_positions[i]

func _parse_rotate(vector: Vector2i, rotate_direction: TurnDirection) -> Vector2i:
	return Vector2i(vector.y, vector.x * -1) if rotate_direction == TurnDirection.Left else Vector2i(vector.y * -1, vector.x)

func _random_food_position() -> Vector2i:
	var all_spaces = _position_space()
	var unavailable_spaces = {}
	for uneaten_food_position in food_states.filter(func(_state): return not _state.is_eaten):
		unavailable_spaces[uneaten_food_position.position] = true
	unavailable_spaces[snake_state.head] = true
	for segment_position in snake_state.tail:
		unavailable_spaces[segment_position] = true
	var available_spaces = all_spaces.filter(func(_point): return not unavailable_spaces.has(_point))
	return available_spaces.pick_random()

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

func _random_polarity() -> Polarity:
	var random_int = randi_range(0, 2)
	match random_int:
		0:
			return Polarity.Organic
		1:
			return Polarity.Paper
		2:
			return Polarity.Plastic
		_:
			return Polarity.Organic

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

func _position_space() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(_top_left().x, _bottom_right().x):
		for y in range(_top_left().y, _bottom_right().y):
			result.push_back(Vector2i(x, y))
	return result
