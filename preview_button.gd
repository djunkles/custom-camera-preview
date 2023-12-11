@tool
extends MenuButton

signal preview_toggled
signal aspect_selected
signal mask_button_pressed

var aspect_mode: int = 0

var pop : PopupMenu
var pop_visible: bool = false

@onready var cull_mask_window: Window = $CullMaskWindow
@onready var button_grp_a: GridContainer = %ButtonGrpA
@onready var button_grp_b: GridContainer = %ButtonGrpB


func _enter_tree():
	pop = get_popup()
	pop.clear()
	pop.add_check_item("Visible")
	pop.add_separator("Aspect Ratio")
	pop.add_radio_check_item("Unconstrained")
	pop.add_radio_check_item("4:3")
	pop.add_radio_check_item("16:9")
	pop.add_radio_check_item("16:10")
	pop.add_separator("")
	pop.add_item("Editor Cull Mask...")
	pop.set_item_checked(2, true)
	pop.id_pressed.connect(item_pressed)

func _ready() -> void:
	# connect button signals
	for child in button_grp_a.get_children():
		child.toggled.connect(_on_button_toggled.bind(child))
	for child in button_grp_b.get_children():
		child.toggled.connect(_on_button_toggled.bind(child))

func _exit_tree():
	pop.id_pressed.disconnect(item_pressed)

func toggle_visibility():
	pop_visible = !pop_visible
	pop.set_item_checked(0, pop_visible)
	preview_toggled.emit(pop_visible)

func select_aspect_mode(id : int):
	pop.set_item_checked(aspect_mode + 2, false)
	aspect_mode = id - 2
	pop.set_item_checked(id, true)
	aspect_selected.emit(aspect_mode)

func item_pressed(id : int):
	if id == 0:
		toggle_visibility()
		return
	# other ids for the aspect options
	if id >= 2 and id <= 5:
		select_aspect_mode(id)
		return
	if id == 7:
		cull_mask_window.show()

func _on_cull_mask_window_close_requested() -> void:
	cull_mask_window.hide()

func _on_button_toggled(toggled_on : bool, button : Button):
	if toggled_on:
		print("Layer " + button.text + " ON")
	if not toggled_on:
		print("Layer " + button.text + " OFF")
	var layer_number = button.text.to_int()
	mask_button_pressed.emit(layer_number)
	
