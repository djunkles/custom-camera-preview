@tool
extends MenuButton

signal preview_toggled
signal aspect_selected
#signal mask_button_pressed
signal set_layers_bitmask(bitmask)

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
	for child in button_grp_a.get_children() + button_grp_b.get_children():
		child.toggled.connect(_on_button_toggled.bind(child))
	await get_tree().root.ready
	# apply saved visibility layers to editor cam
	_load_layer_settings()

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
	set_layers_bitmask.emit(_get_layers_bitmask())
	_save_layer_settings()
	
func _get_layers_bitmask() -> int:
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

func _load_layer_settings():
	# check for config file
	var config = ConfigFile.new()
	# if it doesn't exist create one
	var err = config.load("user://camera_preview.cfg")
	if err != OK:
		_save_layer_settings()
		config.load("user://camera_preview.cfg")
	# load and set var from file
	var saved_layer_state = config.get_value("visiblity_layers", "layer_state")
	var layer_buttons: Array[Node] = button_grp_a.get_children() + button_grp_b.get_children()
	for i in 20:
		layer_buttons[i].set_pressed_no_signal(saved_layer_state[i])
	
	set_layers_bitmask.emit(_get_layers_bitmask())

func _save_layer_settings():
	var config = ConfigFile.new()
	# set values from current variables
	var layer_state : Array[bool] = []
	layer_state.resize(20)
	for child: Button in button_grp_a.get_children() + button_grp_b.get_children():
		layer_state[child.text.to_int() - 1] = child.button_pressed
	# save file
	config.set_value("visiblity_layers", "layer_state", layer_state)
	config.save("user://camera_preview.cfg")
