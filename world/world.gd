@tool
extends Node2D

@export var scatter_noise: Noise
@export_range(0, 1, 0.01) var scatter_frequency: float
@export var regenerate: bool:
	get:
		return false
	set(value):
		$Worldgen.regenerate(20, randi())
		_generate_map_from_worldgen(20)
@export var tilemap: TileMap
@onready var state_hook: StateHook = $StateHook as StateHook

const outer_span: int = 20
const conversion_scene: PackedScene = preload("res://world/conversion.tscn")

var active_conversion_tiles: Array[Node2D] = []

func _on_state_hook_initialized():
	tilemap.clear()
	randomize()
	$Worldgen.regenerate(state_hook.handle.world_span, randi()) 
	_generate_map_from_worldgen(state_hook.handle.world_span)
	
	for powerup in state_hook.handle.powerup_states:
		if powerup.is_eaten:
			continue
		_set_cell_powerup(powerup.position, powerup.type)

func _generate_map_from_worldgen(span: int):
	tilemap.set_cells_terrain_connect(0, VecExtensions.position_space(-Vector2i.ONE * (span + outer_span), Vector2i.ONE * (span + outer_span)), 0, 3, false)
	tilemap.set_cells_terrain_connect(0, VecExtensions.position_space(-Vector2i.ONE * span, Vector2i.ONE * span), 0, 0, false)
	
	for ceramic_rect in $Worldgen.ceramic_rects():
		var tiles = VecExtensions.position_space(ceramic_rect.position, ceramic_rect.end)
		tilemap.set_cells_terrain_connect(0, tiles, 0, 1, false)
	
	for dirty_spot in $Worldgen.dirty_spots():
		tilemap.set_cells_terrain_connect(0, dirty_spot, 0, 2, false)
	
	for ceramic_single in $Worldgen.ceramic_singles():
		tilemap.set_cells_terrain_path(0, [ceramic_single], 0, 1, false)
	
	var border_space: Array[Vector2i] = VecExtensions.perimeter(Vector2i.ONE * -span - Vector2i.ONE, Vector2i.ONE * span + Vector2i.ONE)
	tilemap.set_cells_terrain_connect(0, border_space, 0, 3, false)

func _on_state_hook_updated():
	tilemap.clear_layer(1)
	for food in state_hook.handle.food_states:
		if food.is_eaten:
			continue
		_set_cell_food(food.position, food.polarity)
	
	if state_hook.handle.flags.any(func(flag): return flag.begins_with("powerup")):
		tilemap.clear_layer(2)
		if "powerup:conversion" in state_hook.handle.flags:
			for active_conversion_tile in active_conversion_tiles:
				active_conversion_tile.queue_free()
			active_conversion_tiles.clear()
		for powerup in state_hook.handle.powerup_states:
			if powerup.is_eaten:
				continue
			_set_cell_powerup(powerup.position, powerup.type)
		
	if "regenerate:powerup" in state_hook.handle.flags:
		for powerup in state_hook.handle.powerup_states:
			if powerup.is_eaten:
				continue
			_set_cell_powerup(powerup.position, powerup.type)

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
		CybersnakeGame.Polarity.Coin:
			source_id = 5
			atlas_coordinate = Vector2i(2, 0)
		_:
			return
	tilemap.set_cell(1, cell_position, source_id, atlas_coordinate)

func _set_cell_powerup(cell_position: Vector2i, type: CybersnakeGame.PowerupType):
	match type:
		CybersnakeGame.PowerupType.Conversion:
			var tile = conversion_scene.instantiate() as Node2D
			tilemap.add_child(tile)
			tile.position = tilemap.map_to_local(cell_position)
			active_conversion_tiles.push_back(tile)
		CybersnakeGame.PowerupType.ExtraLife:
			tilemap.set_cell(2, cell_position, 5, Vector2i(0, 0))
		_:
			return
	
