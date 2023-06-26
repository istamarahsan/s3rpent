extends RefCounted
class_name FoodState

var position: Vector2i
var is_eaten: bool
var polarity: CybersnakeGame.Polarity

func _init():
	self.position = Vector2i.ZERO
	self.is_eaten = false
	self.polarity = CybersnakeGame.Polarity.Organic
