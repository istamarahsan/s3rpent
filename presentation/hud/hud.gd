extends Control

signal toggle_pause

@export var plastic_set: HudSet
@export var organic_set: HudSet
@export var paper_set: HudSet

@onready var time_label: Label               = get_node("%TimeLabel") as Label
@onready var category_bg: TextureRect        = get_node("%CategoryBg") as TextureRect
@onready var category_label: Label           = get_node("%CategoryLabel") as Label
@onready var counter_bg: TextureRect         = get_node("%CounterBg") as TextureRect
@onready var counter_label: Label            = get_node("%CounterLabel") as Label
@onready var pause_button: TextureButton     = get_node("%PauseButton") as TextureButton
@onready var hearts_container: HBoxContainer = get_node("%HeartsContainer") as HBoxContainer
@onready var multiplier_label: Label         = get_node("%MultiplierLabel") as Label
@onready var direction_arrow: TextureRect    = get_node("%DirectionArrow") as TextureRect
@onready var state_hook: StateHook           = $StateHook as StateHook
@onready var scheduler_hook: SchedulerHook   = $SchedulerHook as SchedulerHook
@onready var hearts: Array[Control]          = [
	get_node("%Heart1") as Control,
	get_node("%Heart2") as Control,
	get_node("%Heart3") as Control
]
@onready var organic_score_label: Label      = get_node("%OrganicScoreLabel") as Label
@onready var glass_score_label: Label        = get_node("%GlassScoreLabel") as Label
@onready var plastic_score_label: Label      = get_node("%PlasticScoreLabel") as Label
@onready var total_score_label: Label        = get_node("%TotalScoreLabel") as Label

func _ready():
	pause_button.button_up.connect(func(): toggle_pause.emit())

func _process(delta):
	time_label.text = _format_time(scheduler_hook.time_elapsed())
	counter_label.text = str(ceilf(scheduler_hook.time_conversion_remaining() if (state_hook.handle != null and state_hook.handle.is_conversion_active) else scheduler_hook.time_to_next_transition()))

func _on_state_hook_initialized():
	_to_set(_match_polarity(state_hook.handle.snake_mode))
	_sync_ui()

func _on_state_hook_updated():
	_sync_ui()
	if "transition" in state_hook.handle.flags:
		_to_set(_match_polarity(state_hook.handle.snake_mode))

func _sync_ui():
	_update_hearts()
	category_label.text = "$$$$$$" if state_hook.handle.is_conversion_active else _match_polarity_str(state_hook.handle.snake_mode)
	multiplier_label.text = "X " + str(state_hook.handle.active_point_multiplier)
	direction_arrow.rotation = deg_to_rad(_match_heading(state_hook.handle.snake_heading))
	organic_score_label.text = str(state_hook.handle.food_eaten_so_far_cat[CybersnakeGame.Polarity.Organic])
	glass_score_label.text = str(state_hook.handle.food_eaten_so_far_cat[CybersnakeGame.Polarity.Paper])
	plastic_score_label.text = str(state_hook.handle.food_eaten_so_far_cat[CybersnakeGame.Polarity.Plastic])
	total_score_label.text = str(state_hook.handle.food_eaten_so_far)

func _match_polarity_str(value: CybersnakeGame.Polarity) -> String:
	match value:
		CybersnakeGame.Polarity.Organic:
			return "Organic"
		CybersnakeGame.Polarity.Paper:
			return "Glass"
		CybersnakeGame.Polarity.Plastic:
			return "Plastic"
		_:
			return ""

func _match_polarity(polarity: CybersnakeGame.Polarity) -> HudSet:
	match polarity:
		CybersnakeGame.Polarity.Organic:
			return organic_set
		CybersnakeGame.Polarity.Paper:
			return paper_set
		CybersnakeGame.Polarity.Plastic:
			return plastic_set
		_:
			return null

func _to_set(set: HudSet):
	category_bg.texture = set.category_bg
	counter_bg.texture = set.counter_bg

func _format_time(seconds: float) -> String:
	var minutes_component = int(seconds) / 60
	var seconds_component = int(seconds) % 60

	return str(minutes_component).pad_zeros(2) + ":" + str(seconds_component).pad_zeros(2)

func _update_hearts():
	for heart in hearts:
		heart.visible = false
	for i in range(min(state_hook.handle.lives_left, 3)):
		hearts[i].visible = true

func _match_heading(heading: Vector2i) -> float:
	match heading:
		Vector2i.UP:
			return 90
		Vector2i.RIGHT:
			return 180
		Vector2i.DOWN:
			return 270
		Vector2i.LEFT:
			return 0
		_:
			return 0
