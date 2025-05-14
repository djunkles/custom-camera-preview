@tool
extends MenuButton

const CULL_WINDOW_BASE_SIZE := Vector2(563.0, 248.0)

signal preview_toggled
signal aspect_selected(aspect_ratio, locked)
signal set_layers_bitmask(bitmask)


var pop: PopupMenu
var pop_visible: bool = false

var force_ratio := false
var custom_aspect_ratio : Vector2

@onready var cull_mask_window: Window = $CullMaskWindow
@onready var button_grp_a: GridContainer = %ButtonGrpA
@onready var button_grp_b: GridContainer = %ButtonGrpB
@onready var custom_ratio_menu: PopupPanel = $CustomRatioMenu
@onready var spin_box_h: SpinBox = $CustomRatioMenu/VBoxContainer/HBoxContainer/SpinBoxH
@onready var spin_box_v: SpinBox = $CustomRatioMenu/VBoxContainer/HBoxContainer/SpinBoxV



func _enter_tree():
	pop = get_popup()
	pop.clear()
	pop.add_check_item("Visible")
	pop.add_separator("Aspect Ratio")
	pop.add_check_item("Force Custom Aspect Ratio")
	pop.add_item("Set Custom Ratio...")
	pop.add_separator("")
	pop.add_item("Editor Camera Cull...")
	pop.id_pressed.connect(item_pressed)


func _ready() -> void:
	cull_mask_window.size = CULL_WINDOW_BASE_SIZE * EditorInterface.get_editor_scale()
	# connect button signals
	for spinbox: SpinBox in [spin_box_h, spin_box_v]:
		spinbox.value_changed.connect(_on_custom_ratio_set)
	for child in button_grp_a.get_children() + button_grp_b.get_children():
		child.toggled.connect(_on_button_toggled.bind(child))



func toggle_visibility():
	pop_visible = !pop_visible
	pop.set_item_checked(0, pop_visible)
	preview_toggled.emit(pop_visible)


func item_pressed(id : int):
	if id == 0:
		toggle_visibility()
		return
	if id == 2: # free or constrain ratio
		var checked = pop.is_item_checked(id)
		pop.set_item_checked(id, !checked)
		force_ratio = !checked
		aspect_selected.emit(custom_aspect_ratio, force_ratio)
	# if pressed custom ratio
	if id == 3:
		show_custom_ratio_popup()
	if id == 5: # editor cull mask
		cull_mask_window.show()
	

func show_custom_ratio_popup() -> void:
	custom_ratio_menu.show()
	custom_ratio_menu.position = get_global_mouse_position()


func _on_custom_ratio_set(_value : float) -> void:
	force_ratio = true
	pop.set_item_checked(2, true)
	custom_aspect_ratio = Vector2(spin_box_h.value, spin_box_v.value)
	aspect_selected.emit(custom_aspect_ratio, force_ratio)


func _on_cull_mask_window_close_requested() -> void:
	cull_mask_window.hide()


func _on_button_toggled(toggled_on : bool, button : Button):
	if toggled_on:
		print("Layer " + button.text + " ON")
	if not toggled_on:
		print("Layer " + button.text + " OFF")
	set_layers_bitmask.emit(get_layers_bitmask())


func get_layers_bitmask() -> int:
	var active_layers: Array[int] = []
	# get toggle state of each layer button
	# math their values to make bitmask
	for child: Button in button_grp_a.get_children() + button_grp_b.get_children():
		if child.button_pressed:
			active_layers.append(child.text.to_int())
	var bitmask := 0
	for layer_no: int in active_layers:
		var bit := layer_no - 1
		bitmask += pow(2, bit)
	# godot needs hidden layers 21-32 enabled for the editor
	# add that magic number to bitmask
	bitmask += 4293918720
	return bitmask
