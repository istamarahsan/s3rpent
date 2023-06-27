extends Label

@onready var state_hook: StateHook = $StateHook as StateHook

func _ready():
	text = "Food Counter: 0 | Mode: _"

func _on_state_hook_updated():
	match state_hook.handle.is_game_over:
		false:
			text = "Food Counter: " + \
			str(state_hook.handle.food_eaten_so_far) + \
			" | Mode: " + \
			_polarity_to_str(state_hook.handle.snake_mode) + \
			" | Switch In: " + \
			str(state_hook.handle.ticks_to_snake_mode_transition) + \
			" | Lives: " + \
			str(state_hook.handle.lives_left) + \
			"/" + \
			str(state_hook.handle.max_lives)
		true:
			text = "Game Over! High Score: " + str(state_hook.handle.food_eaten_so_far)
			return
	
func _polarity_to_str(polarity: CybersnakeGame.Polarity) -> String:
	match polarity:
		CybersnakeGame.Polarity.Organic:
			return "Organic"
		CybersnakeGame.Polarity.Plastic:
			return "Plastic"
		CybersnakeGame.Polarity.Paper:
			return "Paper"
		_:
			return "_"
