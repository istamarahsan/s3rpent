extends AudioStreamPlayer2D

enum Channel {
	Sfx,
	Music
}

@export var channel: Channel = Channel.Sfx

func _ready():
	AudioBus.scale_changed.connect(_adjust_scale)
	_adjust_scale()

func _adjust_scale():
	volume_db = lerpf(-60, 0, log(1 + _get_scale() * 9) / log(10))

func _get_scale() -> float:
	match channel:
		Channel.Sfx:
			return AudioBus.sfx_scale
		_:
			return AudioBus.music_scale
