@tool
extends Control

@onready var window: Panel = $Window
@onready var vp: SubViewport = $Window/SubViewportContainer/SubViewport
@onready var vp_container: SubViewportContainer = $Window/SubViewportContainer
 

func _ready() -> void:
	resize_vp()

func get_vp() -> Viewport:
	return vp
	
func toggle_window(toggle):
	window.visible = toggle

func toggle_vp(toggle):
	vp_container.visible = toggle

func resize_vp():
	vp.size = window.size

func _on_window_resized() -> void:
	resize_vp()

