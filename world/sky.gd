extends PointLight2D

var noise_source: FastNoiseLite

func _ready():
	noise_source = texture.noise as FastNoiseLite

func _process(delta):
	noise_source.offset = Vector3(
		noise_source.offset.x - 1 * delta,
		noise_source.offset.y - 1 * delta,
		noise_source.offset.z
		) 
