extends Node

enum UpperState {
	Playing
}

@onready var inner_game: CybersnakeGame = $CybersnakeGame as CybersnakeGame
@onready var game_presentation = $Presentation as Presentation

var state_hooks: Array[StateHook] = []
var upper_state: UpperState = UpperState.Playing
var is_action_cooldown: bool = false

func _ready():
	_connect_game(inner_game)
	for child in _get_tree_rec(self):
		if not child is StateHook:
			continue
		var hook = child as StateHook
		hook.handle = inner_game as GameStateHandle
		state_hooks.push_back(hook)
	for hook in state_hooks:
		hook.emit_signal("updated")

func _connect_game(game: CybersnakeGame):
	game.connect("state_updated", _on_game_state_update)
	
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
