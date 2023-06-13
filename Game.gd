extends Node2D

@export
var tile_size: int = 128

@onready
var snakeHead: Node2D = $SnakeSegmentHead
@onready
var snakeBody: Node2D = $SnakeSegment
@onready
var timer: Timer = $Timer
@onready
var camera: Camera2D = $Camera2D

func _ready():
	snakeHead.position = Vector2.ZERO
	snakeBody.position = snakeHead.position - Vector2.LEFT * tile_size/2

func _input(event):
	if (event.is_action_pressed("ui_accept")):
		if timer.is_stopped():
			$Timer.start()
		else:
			$Timer.stop()

func _on_timer_timeout():
	snakeBody.position = snakeHead.position
	snakeHead.position += Vector2(tile_size, 0)
	camera.position = snakeHead.position
