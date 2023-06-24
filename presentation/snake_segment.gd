extends Node2D
class_name SnakeSegment

enum SegmentType {
	Tail,
	Mid,
	Head
}

@export var _tail_texture: Texture2D
@export var _mid_texture: Texture2D
@export var _head_texture: Texture2D

func setType(type: SegmentType):
	match type:
		SegmentType.Tail: 
			$Sprite2D.texture = _tail_texture
		SegmentType.Mid:
			$Sprite2D.texture = _mid_texture
		SegmentType.Head:
			$Sprite2D.texture = _head_texture
