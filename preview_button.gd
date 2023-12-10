@tool
extends MenuButton

signal preview_toggled
signal aspect_selected

var aspect_mode: int = 0

var pop : PopupMenu
var pop_visible: bool = false

func _enter_tree():
	pop = get_popup()
	pop.clear()
	pop.add_check_item("Visible")
	pop.add_separator("Aspect Ratio")
	pop.add_radio_check_item("Unconstrained")
	pop.set_item_checked(2, true)
	pop.add_radio_check_item("4:3")
	pop.add_radio_check_item("16:9")
	pop.add_radio_check_item("16:10")
	pop.id_pressed.connect(item_pressed)

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
	if id >= 1:
		select_aspect_mode(id)
		return
