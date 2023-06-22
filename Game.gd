extends Node2D

enum TurnDirection {
	Left,
	Right
}

signal food_eaten_updated(food_eaten)

@export
var tile_size: int = 128
@export
var snake_seg_packed_scene: PackedScene
@export
var max_foods: int = 3
@export
var world_size: int = 5
@export
var board_canvas: BoardCanvas

@onready
var snake_head: Node2D = $SnakeSegmentHead
@onready
var timer: Timer = $Timer
@onready
var camera: Camera2D = $Camera2D

var snake_heading := Vector2.RIGHT
var snake_head_position := Vector2.ZERO
var is_act_cooldown: bool = false
var food_eaten: int = 0

# temporary for concepting, please use something else later
var food_positions: Array[Vector2] = [ 
	Vector2(1, 1), 
	Vector2(-1, -1), 
	Vector2(3, 3) 
]
var is_food_eaten: Array[bool] = [
	false, 
	false, 
	false
]

func _ready():
	snake_head.position = Vector2.ZERO
	for food_id in range(food_positions.size()) :
		var food_pos = food_positions[food_id]
	board_canvas.configure(world_size, tile_size)
	board_canvas.set_food_positions(_positions_food_left())

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if timer.is_stopped():
			$Timer.start()
		else:
			$Timer.stop()
	elif event.is_action_pressed("ui_up") and not is_act_cooldown:
		_process_action(TurnDirection.Left)
	elif event.is_action_pressed("ui_down") and not is_act_cooldown:
		_process_action(TurnDirection.Right)

func _on_timer_timeout():
	_process_turn()

func _process_action(dir: TurnDirection):
	is_act_cooldown = true
	var rotate_rad = deg_to_rad(-90 if dir == TurnDirection.Left else 90)
	snake_heading = snake_heading.rotated(rotate_rad)
	camera.rotate(rotate_rad)

func _process_turn():
	is_act_cooldown = false
	
	var next_head_position: Vector2 = snake_head_position + snake_heading
	var is_going_out_of_bounds: bool = next_head_position.abs().x > world_size or next_head_position.abs().y > world_size
	snake_head_position = next_head_position.clamp(
		Vector2(-world_size, -world_size), 
		Vector2(world_size, world_size)
	)
	
	if is_food_eaten.all(func(x): return x == true):
		for food_id in range(is_food_eaten.size()):
			is_food_eaten[food_id] = false
		food_positions = _random_food_positions(food_positions.size())
	
	for food_id in range(is_food_eaten.size()):
		if is_food_eaten[food_id]:
			continue
		if food_positions[food_id] != snake_head_position.round():
			continue
		is_food_eaten[food_id] = true
		food_eaten += 1
		food_eaten_updated.emit(food_eaten)
		break
	
	snake_head.position = snake_head_position * tile_size
	camera.position = snake_head.position
	board_canvas.set_food_positions(_positions_food_left())

func _positions_food_left() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for food_id in range(is_food_eaten.size()):
		if not is_food_eaten[food_id]:
			result.push_back(food_positions[food_id])
	return result

func _random_food_positions(n: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	while result.size() < n:
		var x = randi_range(-world_size, world_size)
		var y = randi_range(-world_size, world_size)
		var pos = Vector2(x, y)
		if result.has(pos) or snake_head_position.round() == pos:
			continue
		else:
			result.push_back(pos)
	return result

func _top_left() -> Vector2:
	return Vector2(-world_size, -world_size)

func _top_right() -> Vector2:
	return Vector2(world_size, -world_size)

func _bottom_right() -> Vector2:
	return Vector2(world_size, world_size)
	
func _bottom_left() -> Vector2:
	return Vector2(-world_size, world_size)
