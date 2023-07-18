extends Node2D

@export var scatter_noise: Noise
@export_range(0, 1, 0.01) var scatter_frequency: float

@onready var tilemap: TileMap = $TileMap as TileMap
@onready var state_hook: StateHook = $StateHook as StateHook

func _on_state_hook_initialized():
	_create_world(Vector2i(-state_hook.handle.world_span, -state_hook.handle.world_span), Vector2i(state_hook.handle.world_span, state_hook.handle.world_span))

func _on_state_hook_updated():
	tilemap.clear_layer(1)
	for food in state_hook.handle.food_states:
		if food.is_eaten:
			continue
		_set_cell_food(food.position - Vector2i.ONE, food.polarity)

func _create_world(from: Vector2i, to: Vector2i):
	var space = VecExtensions.position_space(from-Vector2i.ONE, to-Vector2i.ONE)
	tilemap.set_cells_terrain_connect(0, space, 0, 1, false)
	
	var taken_spots: Dictionary = {}
	for pos in space:
		if taken_spots.has(pos):
			continue
		var scatter_val = scatter_noise.get_noise_2dv(pos)
		if scatter_val >= clampf(lerpf(-1, 1, scatter_frequency), -1, 1):
			continue
		var single = randi_range(0, 2) != 0
		if single:
			var takens = VecExtensions.position_space(pos - Vector2i.ONE, pos + Vector2i.ONE)
			for taken in takens:
				taken_spots[taken] = true
			tilemap.set_cell(0, pos, 2, Vector2i(2, 0))
		elif pos.x < to.x-1 and pos.y < to.y-1:
			var takens = VecExtensions.position_space(pos - Vector2i.ONE, pos + Vector2i.ONE)
			for taken in takens:
				taken_spots[taken] = true
			tilemap.set_pattern(0, pos, tilemap.tile_set.get_pattern(1))
		

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
		_:
			return
	tilemap.set_cell(1, cell_position, source_id, atlas_coordinate)
