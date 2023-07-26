extends Node

func position_space(top_left: Vector2i, bottom_right: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			result.push_back(Vector2i(x, y))
	return result

func perimeter(top_left: Vector2i, bottom_right: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	for x in range(top_left.x, bottom_right.x + 1):
		positions.append(Vector2i(x, top_left.y))
		positions.append(Vector2i(x, bottom_right.y))
	
	for y in range(top_left.y + 1, bottom_right.y - 1 + 1):
		positions.append(Vector2i(top_left.x, y))
		positions.append(Vector2i(bottom_right.x, y))

	return positions

func within_rect(point: Vector2i, top_left: Vector2i, bottom_right: Vector2i) -> bool:
	var minX = min(top_left.x, bottom_right.x)
	var minY = min(top_left.y, bottom_right.y)
	var maxX = max(top_left.x, bottom_right.x)
	var maxY = max(top_left.y, bottom_right.y)
	
	if point.x >= minX and point.x <= maxX and point.y >= minY and point.y <= maxY:
		return true
	else:
		return false
