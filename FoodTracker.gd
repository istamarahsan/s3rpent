extends Node2D

# STILL A BAD WAY PLEASE GOD DO PROPER VIEW COMPONENTS
@export
var game: Node2D
@export
var camera: Camera2D

@onready
var lines: Array[Line2D] = [
	$Line1 as Line2D,
	$Line2 as Line2D,
	$Line3 as Line2D
]

func _ready():
	for line in lines:
		line.visible = false
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2.ZERO)
		add_child(line)

func _process(delta):
	for food_id in range(game.food_positions.size()):
		if game.is_food_eaten[food_id]:
			lines[food_id].visible = false
			continue
		lines[food_id].visible = true
		lines[food_id].set_point_position(1, ((game.food_positions[food_id] - game.snake_head_position).normalized().rotated(-camera.rotation)) * 128)
		
