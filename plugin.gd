@tool
extends EditorPlugin

const CamPreview = preload("./cam_window.tscn")
const PreviewButton = preload("./preview_button.tscn")


var cam_preview_instance
var button_instance

var cam_selected: Camera3D
var pcam: Camera3D

var rt: RemoteTransform3D
var editor_selection = EditorInterface.get_selection()
var editor_camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()

func _enter_tree():
	main_screen_changed.connect(on_main_screen_changed)
	
	cam_preview_instance = CamPreview.instantiate()
	cam_preview_instance.window_closed.connect(on_preview_window_closed)
	cam_preview_instance.sync_pressed.connect(on_selection_changed)
	EditorInterface.get_editor_main_screen().add_child(cam_preview_instance)
	cam_preview_instance.toggle_window(false)

	button_instance = PreviewButton.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_instance)
	button_instance.preview_toggled.connect(preview_pressed)
	button_instance.aspect_selected.connect(aspect_mode_pressed)
	button_instance.set_layers_bitmask.connect(toggle_editor_cull_mask_layer)
	
	editor_selection.selection_changed.connect(on_selection_changed)


func _ready() -> void:
	_load_settings()


func _exit_tree():
	_save_settings()
	main_screen_changed.disconnect(on_main_screen_changed)
	preview_free()
	reset_editor_cull_mask()
	if cam_preview_instance:
		cam_preview_instance.queue_free()
	if button_instance:
		button_instance.queue_free()

func find_a_camera(root) -> Camera3D:
	if root is Camera3D:
		return root
	return null 

func cam_deleted():
	preview_free()
	cam_preview_instance.toggle_vp(false)
	if cam_selected.is_connected("tree_exiting", cam_deleted):
		cam_selected.tree_exiting.disconnect(cam_deleted)

func preview_free():
	if is_instance_valid(pcam):
		pcam.queue_free()
	if is_instance_valid(rt):
		rt.queue_free()
	cam_preview_instance.toggle_vp(false)

func on_selection_changed():
	var selected = editor_selection.get_selected_nodes()
	if not selected.is_empty():
		var cam = find_a_camera(selected[0])
		if cam != null:
			if is_instance_valid(cam_selected):
				if cam_selected.is_connected("tree_exiting", cam_deleted):
					cam_selected.tree_exiting.disconnect(cam_deleted)
			cam_selected = cam
			#remove old camera and remote transform
			preview_free()
			pcam = cam.duplicate()
			rt = RemoteTransform3D.new()
			cam_preview_instance.window.add_child(pcam)
			pcam.make_current()
			cam_preview_instance.toggle_vp(true)
			cam_preview_instance.set_window_title(cam.name)
			cam.add_child(rt)
			cam.tree_exiting.connect(cam_deleted)
			rt.remote_path = pcam.get_path()
			rt.use_global_coordinates = true


func show_all():
	if cam_preview_instance and button_instance.pop_visible == true:
		cam_preview_instance.window.show()
	if button_instance:
		button_instance.show()

func hide_all():
	if cam_preview_instance:
		cam_preview_instance.window.hide()
	if button_instance:
		button_instance.hide()


func on_main_screen_changed(screen : String):
	if screen == "3D":
		show_all()
	else:
		hide_all()

func preview_pressed(toggle):
	cam_preview_instance.toggle_window(toggle)

func aspect_mode_pressed(aspect_ratio: Vector2, locked: bool):
	cam_preview_instance.set_aspect_mode(aspect_ratio, locked)

func on_preview_window_closed():
	button_instance.toggle_visibility()

func toggle_editor_cull_mask_layer(bitmask : int):
	editor_camera.cull_mask = bitmask

func reset_editor_cull_mask():
	for i in 20:
		editor_camera.set_cull_mask_value(i + 1, true)


func _save_settings():
	var config = ConfigFile.new()
	
	var layer_state : Array[bool] = []
	layer_state.resize(20)
	for child: Button in button_instance.button_grp_a.get_children() + button_instance.button_grp_b.get_children():
		layer_state[child.text.to_int() - 1] = child.button_pressed
	config.set_value("preview_aspect_ratio", "custom_aspect_ratio", button_instance.custom_aspect_ratio)
	config.set_value("preview_aspect_ratio", "force_ratio", button_instance.force_ratio)
	config.set_value("visiblity_layers", "layer_state", layer_state)
	# save to file
	config.save("user://camera_preview.cfg")


func _load_settings():
	# check for config file
	var config = ConfigFile.new()
	# if it doesn't exist create one
	var err = config.load("user://camera_preview.cfg")
	if err != OK:
		_save_settings()
		config.load("user://camera_preview.cfg")
	# load and set var from file
	var saved_layer_state = config.get_value("visiblity_layers", "layer_state")
	var layer_buttons: Array[Node] = button_instance.button_grp_a.get_children() + button_instance.button_grp_b.get_children()
	for i in 20:
		layer_buttons[i].set_pressed_no_signal(saved_layer_state[i])
	toggle_editor_cull_mask_layer(button_instance.get_layers_bitmask())
	var saved_custom_ratio = config.get_value("preview_aspect_ratio", "custom_aspect_ratio")
	button_instance.custom_aspect_ratio = saved_custom_ratio
	button_instance.spin_box_h.value = saved_custom_ratio.x
	button_instance.spin_box_v.value = saved_custom_ratio.y
	var saved_force_ratio = config.get_value("preview_aspect_ratio", "force_ratio")
	button_instance.force_ratio = saved_force_ratio
	button_instance.pop.set_item_checked(2, saved_force_ratio)
	# set preview window properties
	cam_preview_instance.set_aspect_mode(saved_custom_ratio, saved_force_ratio)
