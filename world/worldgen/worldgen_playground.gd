@tool
extends Node2D

@export var noise_source: FastNoiseLite
@export var dirty_noise_source: FastNoiseLite
@export_range(1, 100, 1) var world_span: int:
	get:
		return _world_span
	set(value):
		_world_span = value
		_create_world()
@export_range(-1, 1, 0.01) var ceramic_threshold: float:
	get:
		return _ceramic_threshold
	set(value):
		_ceramic_threshold = value
		_create_world()
@export_range(0, 1, 0.001) var frequency: float:
	get:
		return noise_source.frequency
	set(value):
		noise_source.frequency = value
		_create_world()
@export var regenerate: bool:
	get:
		return false
	set(value):
		_create_world()

var _world_span: int = 20
var _ceramic_threshold: float = -0.4

func _ready():
	_create_world()

func _create_world():
	if not $TileMap:
		return
	$TileMap.clear()
	var space = _position_space(
		Vector2i(-_world_span, -_world_span), 
		Vector2i(_world_span, _world_span)
		)
	$TileMap.set_cells_terrain_connect(0, space, 0, 0, false)
	var samples = space.map(func(pos): return {
		"pos": pos,
		"value": noise_source.get_noise_2dv(pos)
	})
	var ceramic_spots = samples.filter(func(val): return val["value"] < _ceramic_threshold).map(func(val): return val["pos"])
	ceramic_spots.shuffle()
	
	var ceramic_rects: Array[Rect2i] = []
	var ceramic_singles: Array[Vector2i] = []
	for spot in ceramic_spots:
		var minimum_rect_bound: Rect2i = Rect2i(spot - Vector2i.ONE, Vector2.ONE * 3)
		var nearby_rect_bound: Rect2i = Rect2i(spot - Vector2i.ONE * 5, Vector2.ONE * 10)
		var is_single: bool = ceramic_rects.any(func(rect): return (not rect.intersects(minimum_rect_bound)) and rect.intersects(nearby_rect_bound))
		if is_single:
			ceramic_singles.push_back(spot)
			continue
		
		var final_rect: Rect2i = Rect2i(spot, Vector2i(randi_range(5, 20), randi_range(5, 20)))
		if ceramic_rects.any(func(rect): return final_rect.grow(8).intersects(rect)):
			continue
		ceramic_rects.push_back(final_rect)
	
	var dirty_spots: Array[Vector2i] = []
	
	for rect in ceramic_rects:
		var taken_spots: Dictionary = {}
		var padding: int = 1
		var dirty_possibility_space = _position_space(rect.position + Vector2i.ONE * padding, rect.end - Vector2i.ONE * padding)
		
		for global_pos in dirty_possibility_space:
			if taken_spots.has(global_pos):
				continue
			var scatter_val = dirty_noise_source.get_noise_2dv(global_pos)
			if scatter_val >= clampf(lerpf(-1, 1, 0.3), -1, 1):
				continue
			var single = randi_range(0, 2) != 0
			if single:
				var space_buffered = _position_space(global_pos - Vector2i.ONE, global_pos + Vector2i.ONE)
				for taken_pos in space_buffered:
					taken_spots[taken_pos] = true
				dirty_spots.push_back(global_pos)
			elif global_pos.x < rect.end.x-1 and global_pos.y < rect.end.y-1:
				var space_buffered = _position_space(global_pos - Vector2i.ONE, global_pos + Vector2i.ONE * 2)
				for taken_pos in space_buffered:
					taken_spots[taken_pos] = true
				dirty_spots.append_array(_position_space(global_pos, global_pos + Vector2i.ONE))
	
	for rect in ceramic_rects:
		$TileMap.set_cells_terrain_connect(0, _position_space(rect.position, rect.end), 0, 1, false)
	
	$TileMap.set_cells_terrain_connect(0, dirty_spots, 0, 2, false)
	
	for single in ceramic_singles:
		$TileMap.set_cells_terrain_path(0, [single], 0, 1, false)

func _position_space(top_left: Vector2i, bottom_right: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			result.push_back(Vector2i(x, y))
	return result

func _within_rect(point: Vector2i, top_left: Vector2i, bottom_right: Vector2i) -> bool:
	var minX = min(top_left.x, bottom_right.x)
	var minY = min(top_left.y, bottom_right.y)
	var maxX = max(top_left.x, bottom_right.x)
	var maxY = max(top_left.y, bottom_right.y)
	
	if point.x >= minX and point.x <= maxX and point.y >= minY and point.y <= maxY:
		return true
	else:
		return false
