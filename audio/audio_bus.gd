extends Node

signal scale_changed

var _master_scale: float = 1

@export_range(0, 1, 0.01) var master_scale: float:
	get:
		return _master_scale
	set(value):
		_master_scale = clampf(value, 0, 1)
		scale_changed.emit()

func _ready():
	scale_changed.emit()
