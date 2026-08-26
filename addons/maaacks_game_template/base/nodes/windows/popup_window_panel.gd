@tool
class_name PopupWindowPanel
extends WindowPanel

@export var pauses_game : bool = false :
	set(value):
		pauses_game = value
		if pauses_game:
			process_mode = PROCESS_MODE_ALWAYS
		else:
			process_mode = PROCESS_MODE_INHERIT
@export var makes_mouse_visible : bool = true
@export var exclusive : bool = true
@export var parent_scene : PackedScene

var _initial_pause_state : bool = false
var _initial_mouse_mode : Input.MouseMode
var _initial_focus_control
var _initial_node_focus_modes : Dictionary
var _initial_tab_focus_modes : Dictionary
var _scene_tree : SceneTree 
var _parent_instance : Node
var _is_reparenting : bool = false

func _set_focus_none(node : Node) -> void:
	var all_children := node.get_children()
	for child in all_children:
		if child == self or (child is Control and not child.visible):
			continue
		if child is Control:
			_initial_node_focus_modes[child] = child.focus_mode
			child.focus_mode = Control.FOCUS_NONE
			if child is TabContainer:
				_initial_tab_focus_modes[child] = child.tab_focus_mode
				child.tab_focus_mode = Control.FOCUS_NONE
		_set_focus_none(child)

func _set_focus_initial() -> void:
	for node in _initial_node_focus_modes:
		if is_instance_valid(node) and node is Control:
			node.focus_mode = _initial_node_focus_modes[node]
	_initial_node_focus_modes.clear()
	for node in _initial_tab_focus_modes:
		if is_instance_valid(node) and node is TabContainer:
			node.tab_focus_mode = _initial_tab_focus_modes[node]
	_initial_tab_focus_modes.clear()

func close() -> void:
	if _is_reparenting: return
	if not visible: return
	if pauses_game:
		_scene_tree.paused = _initial_pause_state
	Input.set_mouse_mode(_initial_mouse_mode)
	_set_focus_initial()
	if is_instance_valid(_initial_focus_control) and _initial_focus_control.is_inside_tree():
		_initial_focus_control.grab_focus()
	if _parent_instance:
		_parent_instance.hide()
	super.close()

func _overlaid_window_setup():
	if _scene_tree:
		_initial_pause_state = _scene_tree.paused
	_initial_mouse_mode = Input.get_mouse_mode()
	_initial_focus_control = get_viewport().gui_get_focus_owner()
	if _initial_focus_control:
		_initial_focus_control.release_focus()
	if Engine.is_editor_hint(): return
	if _scene_tree:
		_scene_tree.paused = pauses_game or _initial_pause_state
	if makes_mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if exclusive and get_tree().current_scene:
		_set_focus_none(get_tree().current_scene)
	if _parent_instance:
		_parent_instance.show()
		set_anchors_and_offsets_preset(Control.PRESET_CENTER)

func _setup_parent_instance():
	if Engine.is_editor_hint():
		return
	if _scene_tree.current_scene and _scene_tree.current_scene == self:
		return
	if parent_scene is PackedScene and (not is_instance_valid(_parent_instance)):
		_parent_instance = parent_scene.instantiate()
		_parent_instance.name = "%s%s" % [name, _parent_instance.name] 
		add_sibling.call_deferred(_parent_instance)
		await _parent_instance.ready
		_is_reparenting = true
		var _was_visible = visible
		if not visible:
			size += Vector2.ONE
			show.call_deferred()
			reset_size.call_deferred()
			await resized
		var _canvas_layer_node = get_canvas_layer_node()
		reparent.call_deferred(_parent_instance)
		await tree_entered
		if _parent_instance is CanvasLayer and _canvas_layer_node:
			_parent_instance.layer = _canvas_layer_node.layer * 2
		_is_reparenting = false
		visible = _was_visible

func _setup():
	_setup_parent_instance()

func _ready() -> void:
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	super._ready()
	_setup()

func _on_visibility_changed() -> void:
	if _is_reparenting:
		return
	if _parent_instance:
		_parent_instance.visible = visible
	if is_visible_in_tree():
		_overlaid_window_setup()

func _enter_tree() -> void:
	_scene_tree = get_tree()
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()
