extends Node2D

@export var scatter_noise: Noise
@export_range(0, 1, 0.01) var scatter_frequency: float

@onready var tilemap: TileMap = $TileMap as TileMap
@onready var state_hook: StateHook = $StateHook as StateHook

func _on_state_hook_initialized():
	$Worldgen.regenerate(state_hook.handle.world_span)
	tilemap.set_cells_terrain_connect(0, VecExtensions.position_space(-Vector2i.ONE * state_hook.handle.world_span, Vector2i.ONE * state_hook.handle.world_span), 0, 0, false)
	for ceramic_rect in $Worldgen.ceramic_rects():
		var tiles = VecExtensions.position_space(ceramic_rect.position, ceramic_rect.end)
		tilemap.set_cells_terrain_connect(0, tiles, 0, 1, false)
	for dirty_spot in $Worldgen.dirty_spots():
		tilemap.set_cells_terrain_connect(0, dirty_spot, 0, 2, false)
	for ceramic_single in $Worldgen.ceramic_singles():
		tilemap.set_cells_terrain_path(0, [ceramic_single], 0, 1, false)
	var border_space: Array[Vector2i] = VecExtensions.perimeter(Vector2i.ONE * -state_hook.handle.world_span - Vector2i.ONE, Vector2i.ONE * state_hook.handle.world_span + Vector2i.ONE)
	tilemap.set_cells_terrain_connect(0, border_space, 0, 3, false)

func _on_state_hook_updated():
	tilemap.clear_layer(1)
	for food in state_hook.handle.food_states:
		if food.is_eaten:
			continue
		_set_cell_food(food.position, food.polarity)

func _match_polarity_terrain(polarity: CybersnakeGame.Polarity) -> int:
	match polarity:
		CybersnakeGame.Polarity.Organic:
			return 0
		CybersnakeGame.Polarity.Paper:
			return 1
		CybersnakeGame.Polarity.Plastic:
			return 2
		_:
			return 0

var alt_memo: Dictionary = {}

func _set_cell_food(cell_position: Vector2i, polarity: CybersnakeGame.Polarity):
	if cell_position not in alt_memo:
		alt_memo[cell_position] = randi() % 2 == 0
	
	var alt: bool = alt_memo[cell_position]
	var source_id: int = 4
	var atlas_coordinate: Vector2i
	match polarity:
		CybersnakeGame.Polarity.Organic:
			atlas_coordinate = Vector2i(2, 0) if alt else Vector2i(0, 1)
		CybersnakeGame.Polarity.Paper:
			atlas_coordinate = Vector2i(1, 0) if alt else Vector2i(0, 0)
		CybersnakeGame.Polarity.Plastic:
			atlas_coordinate = Vector2i(1, 1)
		_:
			return
	tilemap.set_cell(1, cell_position, source_id, atlas_coordinate)
