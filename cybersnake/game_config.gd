extends Resource
class_name GameConfig

@export_range(5, 100, 1) var initial_world_span: int
@export_range(0.01, 1, 0.01) var food_rarity: float = 0.01
@export_range(0.01, 1, 0.01) var powerups_rarity: float
@export var powerups_cap: int
@export var food_cap: int
@export var snake_mode_interval: int
@export_range(1, 10, 1) var max_lives: int
@export_range(1, 999, 1) var conversion_duration: int
@export_range(1, 10, 1) var initial_length: int
