extends Node

func position_space(top_left: Vector2i, bottom_right: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			result.push_back(Vector2i(x, y))
	return result
