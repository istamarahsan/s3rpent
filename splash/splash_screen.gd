extends Control
class_name SplashScreen

@export_range(0.1, 5, 0.01) var fade_in: float = 1
@export_range(0.1, 5, 0.01) var hold: float = 1
@export_range(0.1, 5, 0.01) var fade_out: float = 1

@onready var fade_bg: Control = $FadeBg
@onready var splash: Control = $Splash

func _ready():
	splash.modulate.a = 0

func do_splash():
	splash.modulate.a = 0
	
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(
		splash, 
		"modulate", 
		Color(splash.modulate.r, splash.modulate.g, splash.modulate.b, 1), 
		fade_in)
	await fade_in_tween.finished
	
	await get_tree().create_timer(hold).timeout
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(
		splash, 
		"modulate", 
		Color(splash.modulate.r, splash.modulate.g, splash.modulate.b, 0), 
		fade_out)
	await fade_out_tween.finished
	
	fade_bg.visible = false
