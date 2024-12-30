@tool
extends Control
signal window_closed
signal sync_pressed

const ASPECTS = [(4.0 / 3.0), (16.0 / 9.0), (16.0 / 10.0)]

var locked_aspect := false
var aspect_multiplier : float

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



func _process(delta: float) -> void:
	if locked_aspect:
		window.size.x = window.size.y * aspect_multiplier

func _on_window_close_requested() -> void:
	toggle_window(false)
	window_closed.emit()

func toggle_window(toggle : bool):
	window.visible = toggle

func toggle_vp(toggle : bool):
	label.visible = !toggle
	sync_button.visible = toggle

func set_aspect_mode(aspect_mode : int):
	if aspect_mode == 0:
		locked_aspect = false
		return
	if aspect_mode >= 1:
		locked_aspect = true
		aspect_multiplier = ASPECTS[aspect_mode - 1]
		window.set_size(Vector2(window.size.y * aspect_multiplier, window.size.y))
		return

func set_window_title(title_text : String):
	window.title = "Camera Preview (" + title_text + ")"


func _on_sync_button_pressed() -> void:
	sync_pressed.emit()
