extends Node2D

enum TurnDirection {
	Left,
	Right
}

var is_act_cooldown: bool = false

@export
var tile_size: int = 128
@export
var snake_seg_packed_scene: PackedScene

@onready
var snake_head: Node2D = $SnakeSegmentHead
@onready
var timer: Timer = $Timer
@onready
var camera: Camera2D = $Camera2D

var active_direction := Vector2.RIGHT

func _ready():
	snake_head.position = Vector2.ZERO

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
	snake_head.position += active_direction * tile_size
	camera.position = snake_head.position
	is_act_cooldown = false

func _process_action(dir: TurnDirection):
	is_act_cooldown = true
	var rotate_rad = deg_to_rad(-90 if dir == TurnDirection.Left else 90)
	active_direction = active_direction.rotated(rotate_rad)
	camera.rotate(rotate_rad)
