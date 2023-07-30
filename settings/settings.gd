extends Control
class_name Settings

signal back

@export var sfx_slider: Slider
@export var music_slider: Slider
@export var resolution_option_button: OptionButton
@export var enable_fullscreen_checkbox: Button
@export var feedback_link_button: LinkButton

const form_url_endpoint = "https://cybersnakeapi.istamarsan.dev/feedback"

var resolution_options: Dictionary = {
	"1920x1080" : Vector2i(1920,1080),
	"1600x900"  : Vector2i(1600,900),
	"1280x720"  : Vector2i(1280,720)
}

func _ready():
	resolution_option_button.clear()
	for option in resolution_options:
		resolution_option_button.add_item(option)
	resolution_option_button.disabled = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	enable_fullscreen_checkbox.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	sfx_slider.min_value = 0
	sfx_slider.max_value = 1
	sfx_slider.step = 0.01
	music_slider.min_value = 0
	music_slider.max_value = 1
	music_slider.step = 0.01
	_on_scale_changed()
	AudioBus.scale_changed.connect(_on_scale_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	
	$FetchFormLink.request(
		form_url_endpoint,
		["authorization: Bearer there_is_no_authorization"]
	)
	
func _on_scale_changed():
	sfx_slider.value = AudioBus.sfx_scale
	music_slider.value = AudioBus.music_scale

func _on_sfx_slider_value_changed(value: float):
	AudioBus.sfx_scale = value

func _on_music_slider_value_changed(value: float):
	AudioBus.music_scale = value

func _on_option_button_item_selected(index):
	var size = resolution_options.get(resolution_option_button.get_item_text(index))
	get_window().size=size

func _on_check_box_toggled(enable_fullscreen):
	if enable_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	resolution_option_button.disabled = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_back_button_up():
	back.emit()

func _on_fetch_form_link_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	
	var data = JSON.parse_string(body)
	
	$Buttons/VBoxContainer/Feedback.visible = true
	feedback_link_button.disabled = false
	feedback_link_button.uri = data["formUrl"]
