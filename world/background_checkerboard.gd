extends Node2D

@onready var tilemap: TileMap = $TileMap as TileMap

func create(from: Vector2i, to: Vector2i):
	for x in range(from.x, to.x+1):
		for y in range(from.y, to.y+1):
			var alt: bool = (x + y) % 2 == 0
			tilemap.set_cell(
				0, 
				Vector2i(x, y), 
				0, 
				Vector2i(0,0) if alt else Vector2i(1,0)
				)
