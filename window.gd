@tool
extends Panel

const Aspects = [(4.0 / 3.0), (16.0 / 9.0), (16.0 / 10.0)]

var locked_aspect := false
var aspect_multiplier : float
var dragging := false
var resizing := false
var mouse_offset : Vector2

func _process(_delta) -> void:
	if dragging:
		var movement = get_local_mouse_position() - mouse_offset
		set_position(position + movement)
	if resizing:
		var new_size = get_local_mouse_position()
		set_size(new_size)
		if locked_aspect:
			size.x = size.y * aspect_multiplier


func _on_window_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			mouse_offset = get_local_mouse_position()

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			resizing = event.pressed
			mouse_offset = get_local_mouse_position()

func set_aspect_mode(aspect_mode : int):
	if aspect_mode == 0:
		locked_aspect = false
		return
	if aspect_mode >= 1:
		locked_aspect = true
		aspect_multiplier = Aspects[aspect_mode - 1]
		set_size(Vector2(size.y * aspect_multiplier, size.y))
		return
