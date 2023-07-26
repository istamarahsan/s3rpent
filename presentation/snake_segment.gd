extends Node2D
class_name SnakeSegment

enum SegmentType {
	Tail,
	Body,
	CornerRight,
	CornerLeft,
	Head
}

func set_polarity(polarity: CybersnakeGame.Polarity):
	pass

func setType(type: SegmentType):
	pass

func flash_hit():
	pass
