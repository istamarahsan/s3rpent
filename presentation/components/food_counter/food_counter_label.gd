extends Label

@onready var state_hook: StateHook = $StateHook as StateHook

func _ready():
	text = "Food Counter: 0"

func _on_state_hook_updated():
	text = "Food Counter: " + str(state_hook.handle.food_eaten_so_far)
