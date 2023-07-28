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

const glitch_material: ShaderMaterial = preload("res://presentation/snake/snake_segment.tres")

var polarity: CybersnakeGame.Polarity = CybersnakeGame.Polarity.Organic
var type: SegmentType = SegmentType.Body

var polarity_hitflash_conf: Dictionary = {
	CybersnakeGame.Polarity.Organic: 0.3,
	CybersnakeGame.Polarity.Paper: 0.015,
	CybersnakeGame.Polarity.Plastic: 0.015
}

func set_polarity(polarity: CybersnakeGame.Polarity):
	self.polarity = polarity
	_update_texture()

func setType(type: SegmentType):
	self.type = type
	_update_texture()

var _flashing: bool = false

func flash_hit():
	if _flashing:
		return
	_flashing = true
	
	
	
	$Sprite.material.set_shader_parameter("shake_rate", 1)
	
	var max_tween = get_tree().create_tween()
	max_tween.tween_method(
		func(degree):
			$Sprite.material.set_shader_parameter("shake_power", degree),
		0.0,
		polarity_hitflash_conf[polarity],
		0.25
	)
	await max_tween.finished
	
	var min_tween = get_tree().create_tween()
	min_tween.tween_method(
		func(degree):
			$Sprite.material.set_shader_parameter("shake_power", degree),
		polarity_hitflash_conf[polarity],
		0.0,
		0.25
	)
	await min_tween.finished
	$Sprite.material.set_shader_parameter("shake_rate", 0)
#	$Sprite.material.set_shader_parameter("flash_color", flash_color)
#	$Sprite.material.set_shader_parameter("shake_rate", 1.0)
#	$FlashTimer.wait_time = flash_time_seconds_hit
#	$FlashTimer.start()
#	await $FlashTimer.timeout
#	$Sprite.material.set_shader_parameter("shake_rate", 0.0)
#	$FlashTimer.wait_time = flash_interval_seconds_hit
#	$FlashTimer.start()
	_flashing = false

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
