extends SnakeSegment

@export var plastic_set: SnakeTheme
@export var glass_set: SnakeTheme
@export var organic_set: SnakeTheme
@export_category("FX")
@export_subgroup("Hit")
@export_range(0.05, 3, 0.01) var flash_time_seconds_hit: float = 0.05
@export_range(0.05, 3, 0.01) var flash_interval_seconds_hit: float = 0.05
@export_range(1, 10, 1) var flash_times: int = 3
@export var flash_color: Color

var polarity: CybersnakeGame.Polarity = CybersnakeGame.Polarity.Organic
var type: SegmentType = SegmentType.Body

func set_polarity(polarity: CybersnakeGame.Polarity):
	self.polarity = polarity
	_update_texture()

func setType(type: SegmentType):
	self.type = type
	_update_texture()

func flash_hit():
	$Sprite.material.set_shader_parameter("flash_color", flash_color)
	for time in range(flash_times):
		$Sprite.material.set_shader_parameter("degree", 1)
		$FlashTimer.wait_time = flash_time_seconds_hit
		$FlashTimer.start()
		await $FlashTimer.timeout
		$Sprite.material.set_shader_parameter("degree", 0)
		$FlashTimer.wait_time = flash_interval_seconds_hit
		$FlashTimer.start()
		await $FlashTimer.timeout

func _update_texture():
	var theme = _match_polarity()
	var texture: Texture2D
	match type:
		SegmentType.Head:
			texture = theme.head
		SegmentType.Body:
			texture = theme.body
		SegmentType.CornerRight:
			texture = theme.corner_right
		SegmentType.CornerLeft:
			texture = theme.corner_left
		SegmentType.Tail:
			texture = theme.tail
	$Sprite.texture = texture

func _match_polarity() -> SnakeTheme:
	match polarity:
		CybersnakeGame.Polarity.Organic:
			return organic_set
		CybersnakeGame.Polarity.Paper:
			return glass_set
		CybersnakeGame.Polarity.Plastic:
			return plastic_set
	return organic_set
