extends RefCounted
class_name PowerupState

enum PowerupType {
	ExtraLife,
	Conversion
}

var position: Vector2i
var type: PowerupType
