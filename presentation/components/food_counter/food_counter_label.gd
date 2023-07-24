extends Label

@onready var state_hook: StateHook = $StateHook as StateHook

func _ready():
	text = "Food Counter: 0 | Mode: _"

func _on_state_hook_updated():
	match state_hook.handle.is_game_over:
		false:
			text = "Points: " + \
			str(state_hook.handle.points) + \
			" | Mode: " + \
			_polarity_to_str(state_hook.handle.snake_mode) + \
			" | Switch In: " + \
			str(state_hook.handle.ticks_to_snake_mode_transition) + \
			" | Lives: " + \
			str(state_hook.handle.lives_left) + \
			"/" + \
			str(state_hook.handle.max_lives) + \
			" | Mult: " + \
			str(state_hook.handle.active_point_multiplier) + \
			 "x"
			add_theme_color_override("font_outline_color", _polarity_to_color(state_hook.handle.snake_mode))
		true:
			text = "Game Over! High Score: " + str(state_hook.handle.points)
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

func _polarity_to_color(polarity: CybersnakeGame.Polarity) -> Color:
	match polarity:
		CybersnakeGame.Polarity.Organic:
			return "green"
		CybersnakeGame.Polarity.Plastic:
			return "black"
		CybersnakeGame.Polarity.Paper:
			return "red"
		_:
			return "white"
