extends Node2D

@export
var tile_size: int = 128
@onready var cybersnake: CybersnakeGame = $Cybersnake

func _ready():
	cybersnake.action_turn(CybersnakeGame.TurnDirection.Left)
	cybersnake.process_timestep()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		pass
	elif event.is_action_pressed("ui_up"):
		pass
	elif event.is_action_pressed("ui_down"):
		pass

func _on_cybersnake_state_update(gamestate, flags):
	var state = gamestate
	print(str(state.snake_state.head))
