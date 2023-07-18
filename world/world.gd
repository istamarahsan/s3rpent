extends Node2D

@onready var tilemap: TileMap = $TileMap as TileMap
@onready var state_hook: StateHook = $StateHook as StateHook

func _on_state_hook_initialized():
	_create_world(Vector2i(-state_hook.handle.world_span-1, -state_hook.handle.world_span-1), Vector2i(state_hook.handle.world_span-1, state_hook.handle.world_span-1))

func _on_state_hook_updated():
	tilemap.clear_layer(1)
	for food in state_hook.handle.food_states:
		if food.is_eaten:
			continue
		_set_cell_food(food.position - Vector2i.ONE, food.polarity)

func _create_world(from: Vector2i, to: Vector2i):
	for x in range(from.x, to.x+1):
		for y in range(from.y, to.y+1):
			var alt: bool = (x + y) % 2 == 0
			tilemap.set_cell(
				0, 
				Vector2i(x, y), 
				0, 
				Vector2i(0,0) if alt else Vector2i(1,0)
				)

func _set_cell_food(cell_position: Vector2i, polarity: CybersnakeGame.Polarity):
	var source_id: int = 1
	var atlas_coordinate: Vector2i
	match polarity:
		CybersnakeGame.Polarity.Organic:
			atlas_coordinate = Vector2i(2, 0)
		CybersnakeGame.Polarity.Paper:
			atlas_coordinate = Vector2i(0, 0)
		CybersnakeGame.Polarity.Plastic:
			atlas_coordinate = Vector2i(3, 0)
	tilemap.set_cell(1, cell_position, source_id, atlas_coordinate)
