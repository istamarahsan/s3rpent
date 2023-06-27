extends Node

enum UpperState {
	Playing
}

@export var game_scene: PackedScene

@onready var inner_game: CybersnakeGame
@onready var game_presentation = $Presentation as Presentation

var state_hooks: Array[StateHook] = []
var upper_state: UpperState = UpperState.Playing
var is_action_cooldown: bool = false

func _ready():
	_recreate_game()

func _recreate_game():
	if inner_game != null:
		inner_game.queue_free()
	inner_game = game_scene.instantiate() as CybersnakeGame
	add_child(inner_game)
	_connect_game(inner_game)
	_connect_hooks(inner_game)

func _connect_game(game: CybersnakeGame):
	game.connect("state_updated", _on_game_state_update)

func _connect_hooks(game: CybersnakeGame):
	state_hooks.clear()
	for child in _get_tree_rec(self):
		if not child is StateHook:
			continue
		var hook = child as StateHook
		hook.handle = game as GameStateHandle
		state_hooks.push_back(hook)
	for hook in state_hooks:
		hook.emit_signal("updated")

func _on_game_state_update(_state, _flags):
	for hook in state_hooks:
		hook.emit_signal("updated")
	
func _get_tree_rec(root: Node) -> Array[Node]:
	var nodes: Array[Node] = [root]
	for child in root.get_children():
		nodes.append_array(_get_tree_rec(child))
	return nodes

func _on_turn_input_left_pressed():
	if is_action_cooldown:
		return
	is_action_cooldown = true
	inner_game.action_turn(CybersnakeGame.TurnDirection.Left)

func _on_turn_input_right_pressed():
	if is_action_cooldown:
		return
	is_action_cooldown = true
	inner_game.action_turn(CybersnakeGame.TurnDirection.Right)

func _on_timer_timeout():
	inner_game.process_timestep()
	is_action_cooldown = false

func _on_demo_ui_request_replay():
	_recreate_game()
