extends SnakeSegment

@export var _tail_texture: Texture2D
@export var _body_texture: Texture2D
@export var _corner_texture: Texture2D
@export var _head_texture: Texture2D
@export var _sprite: Sprite2D
@export var _flash_timer: Timer
@export_category("FX")
@export_subgroup("Hit")
@export_range(0.05, 3, 0.01) var flash_time_seconds_hit: float = 0.05
@export_range(0.05, 3, 0.01) var flash_interval_seconds_hit: float = 0.05
@export_range(1, 10, 1) var flash_times: int = 3
@export var flash_color: Color

var _base_rotation: float = -deg_to_rad(90)

func setType(type: SnakeSegment.SegmentType):
	_sprite.flip_h = false
	match type:
		SnakeSegment.SegmentType.Tail: 
			_sprite.texture = _tail_texture
		SnakeSegment.SegmentType.Body:
			_sprite.texture = _body_texture
		SnakeSegment.SegmentType.CornerRight:
			_sprite.flip_h = true
			_sprite.texture = _corner_texture
		SnakeSegment.SegmentType.CornerLeft:
			_sprite.texture = _corner_texture
		SnakeSegment.SegmentType.Head:
			_sprite.texture = _head_texture

func flash_hit():
	_sprite.material.set_shader_parameter("flash_color", flash_color)
	for time in range(flash_times):
		_sprite.material.set_shader_parameter("degree", 1)
		_flash_timer.wait_time = flash_time_seconds_hit
		_flash_timer.start()
		await _flash_timer.timeout
		_sprite.material.set_shader_parameter("degree", 0)
		_flash_timer.wait_time = flash_interval_seconds_hit
		_flash_timer.start()
		await _flash_timer.timeout
