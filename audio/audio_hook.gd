extends AudioStreamPlayer

func _ready():
	AudioBus.scale_changed.connect(_adjust_scale)
	_adjust_scale()

func _adjust_scale():
	volume_db = lerpf(-60.0, 0.0, AudioBus.master_scale)
