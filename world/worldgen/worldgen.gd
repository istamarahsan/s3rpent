@tool
extends Node
class_name Worldgen

@export var noise_source: FastNoiseLite
@export var dirty_noise_source: FastNoiseLite
@export_range(-1, 1, 0.01) var ceramic_threshold: float
@export_range(0, 1, 0.001) var frequency: float

var _world: Dictionary = {}
var _ceramic_singles: Array[Vector2i] = []
var _ceramic_rects: Array[Rect2i] = []
var _dirty_spots: Array[Array] = []

const dirty_offset: int = 15

func regenerate(span: int, seed: int = 0):
	noise_source.seed = seed
	dirty_noise_source.seed = seed + dirty_offset
	seed(seed)
	
	_world = {}
	var space = VecExtensions.position_space(
		Vector2i(-span, -span), 
		Vector2i(span, span)
		)
	var samples = space.map(func(pos): return {
		"pos": pos,
		"value": noise_source.get_noise_2dv(pos)
	})
	var ceramic_spots = samples.filter(func(val): return val["value"] < ceramic_threshold).map(func(val): return val["pos"])
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
		if not Rect2i(-span+1, -span+1, 1+2*span-2, 1+2*span-2).encloses(final_rect) or ceramic_rects.any(func(rect): return final_rect.grow(8).intersects(rect)):
			continue
		ceramic_rects.push_back(final_rect)
	
	var dirty_spots: Array[Array] = []
	for rect in ceramic_rects:
		var taken_spots: Dictionary = {}
		var padding: int = 1
		var dirty_possibility_space = VecExtensions.position_space(rect.position + Vector2i.ONE * padding, rect.end - Vector2i.ONE * padding)
		
		for global_pos in dirty_possibility_space:
			if taken_spots.has(global_pos):
				continue
			var scatter_val = dirty_noise_source.get_noise_2dv(global_pos)
			if scatter_val >= clampf(lerpf(-1, 1, 0.3), -1, 1):
				continue
			var single = randi_range(0, 2) != 0
			if single:
				var space_buffered = VecExtensions.position_space(global_pos - Vector2i.ONE, global_pos + Vector2i.ONE)
				for taken_pos in space_buffered:
					taken_spots[taken_pos] = true
				dirty_spots.push_back([global_pos])
			elif global_pos.x < rect.end.x-1 and global_pos.y < rect.end.y-1:
				var space_buffered = VecExtensions.position_space(global_pos - Vector2i.ONE, global_pos + Vector2i.ONE * 2)
				for taken_pos in space_buffered:
					taken_spots[taken_pos] = true
				dirty_spots.push_back(VecExtensions.position_space(global_pos, global_pos + Vector2i.ONE))
	
	_ceramic_singles = ceramic_singles
	_ceramic_rects = ceramic_rects
	_dirty_spots = dirty_spots

func ceramic_singles() -> Array[Vector2i]:
	return _ceramic_singles

func ceramic_rects() -> Array[Rect2i]:
	return _ceramic_rects
	
func dirty_spots() -> Array[Array]:
	return _dirty_spots

