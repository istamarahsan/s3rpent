extends Control
class_name SplashScreen

@export_range(0.1, 5, 0.01) var fade_in: float = 1
@export_range(0.1, 5, 0.01) var hold: float = 1
@export_range(0.1, 5, 0.01) var fade_out: float = 1

@onready var fade_bg: Control = $FadeBg
@onready var splash: Control = $Splash

func do_splash():
	$SplashAnimate.play("Splash")
	await $SplashAnimate.animation_finished
