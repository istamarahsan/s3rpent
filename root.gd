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
	_connect_hooks(inner_game)

func _connect_hooks(game: CybersnakeGame):
	state_hooks.clear()
	for child in _get_tree_rec(self):
		if not child is StateHook:
			continue
		var hook = child as StateHook
		hook.handle = game as GameStateHandle
		state_hooks.push_back(hook)
	_propagate_hook_signal()
	
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
	_propagate_hook_signal()

func _on_turn_input_right_pressed():
	if is_action_cooldown:
		return
	is_action_cooldown = true
	inner_game.action_turn(CybersnakeGame.TurnDirection.Right)
	_propagate_hook_signal()

func _on_timer_timeout():
	inner_game.process_timestep()
	is_action_cooldown = false
	_propagate_hook_signal()

func _on_demo_ui_request_replay():
	_recreate_game()

func _propagate_hook_signal():
	for hook in state_hooks:
		hook.emit_signal("updated")
