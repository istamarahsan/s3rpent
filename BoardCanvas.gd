extends Node2D
class_name BoardCanvas

@export
var board_span: int = 5
@export
var tile_size: int = 128

var food_positions: Dictionary = {}

func configure(board_span: int, tile_size: int):
	self.board_span = board_span
	self.tile_size = tile_size
	queue_redraw()
	
func set_food_positions(positions: Array[Vector2]):
	food_positions = {}
	for pos in positions:
		food_positions[pos] = true
	queue_redraw()
	
func _draw():
	for y in range(-board_span, board_span+1):
		for x in range(-board_span, board_span+1):
			var position = Vector2(x, y)
			var color = _choose_color(position)
			draw_circle(position * tile_size, 10, color)

func _choose_color(position: Vector2):
	if food_positions.has(position):
		return "#32A433"
	return "#FFFFFF"
