extends RefCounted
class_name SnakePositionState

var head: Vector2i
var tail: Array[Vector2i]

func _init():
	self.head = Vector2i.ZERO
	self.tail = []
