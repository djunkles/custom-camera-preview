@tool
extends Control

signal window_closed
signal sync_pressed

var locked_aspect := false
var aspect_multiplier : float
var base_min_size : Vector2

@onready var window: Window = $Window
@onready var label: Label = %Label
@onready var sync_button: Button = %SyncButton


func _ready() -> void:
	# set window size appropriate to screen size
	var window_size: Vector2 = window.size
	var screen_size := get_viewport_rect().size
	if screen_size.y > 1400.0:
		window_size *= 2.0
		sync_button.size *= 2.0
	window.size = window_size
	base_min_size = get_minimum_size()


func _process(delta: float) -> void:
	if locked_aspect:
		window.set_size(Vector2(window.size.y * aspect_multiplier, window.size.y))


func _on_window_close_requested() -> void:
	toggle_window(false)
	window_closed.emit()

func toggle_window(toggle : bool):
	window.visible = toggle

func toggle_vp(toggle : bool):
	label.visible = !toggle
	sync_button.visible = toggle

func set_aspect_mode(aspect_ratio: Vector2, locked: bool):
	locked_aspect = locked
	aspect_multiplier = (aspect_ratio.x / aspect_ratio.y)
	if locked_aspect:
		set_custom_minimum_size(Vector2(base_min_size.y * aspect_multiplier, base_min_size.y))
		window.set_size(Vector2(window.size.y * aspect_multiplier, window.size.y))
	else:
		set_custom_minimum_size(base_min_size)

func set_window_title(title_text : String):
	window.title = "Camera Preview (" + title_text + ")"


func _on_sync_button_pressed() -> void:
	sync_pressed.emit()
