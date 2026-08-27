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
var _original_parent : Node
var is_reparenting : bool = false
var is_opened : bool = false

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
	if is_reparenting: return
	if not visible: return
	if not is_opened:
		return
	is_opened = false
	if pauses_game:
		_scene_tree.paused = _initial_pause_state
	Input.set_mouse_mode(_initial_mouse_mode)
	_set_focus_initial()
	if is_instance_valid(_initial_focus_control) and _initial_focus_control.is_inside_tree():
		_initial_focus_control.grab_focus()
	if _parent_instance:
		reparent.call_deferred(_original_parent)
		_parent_instance.queue_free()
	super.close()

func _setup_parent_instance():
	if Engine.is_editor_hint():
		return
	if _scene_tree.current_scene and _scene_tree.current_scene == self:
		return
	if is_instance_valid(_parent_instance):
		return
	if not parent_scene is PackedScene:
		return
	var _canvas_layer_node = get_canvas_layer_node()
	_parent_instance = parent_scene.instantiate()
	_parent_instance.name = "%s%s" % [name, _parent_instance.name] 
	add_sibling.call_deferred(_parent_instance)
	await _parent_instance.ready
	is_reparenting = true
	_original_parent = get_parent()
	reparent.call_deferred(_parent_instance)
	await tree_entered
	if _parent_instance is CanvasLayer:
		var _next_layer = 1
		if _canvas_layer_node:
			_next_layer = _canvas_layer_node.layer * 2
		_parent_instance.layer = _next_layer
	is_reparenting = false

func _open_popup():
	if is_opened:
		return
	is_opened = true
	if _scene_tree:
		_initial_pause_state = _scene_tree.paused
	_initial_mouse_mode = Input.get_mouse_mode()
	_initial_focus_control = get_viewport().gui_get_focus_owner()
	if _initial_focus_control:
		_initial_focus_control.release_focus()
	if Engine.is_editor_hint(): return
	_setup_parent_instance()
	if _scene_tree:
		_scene_tree.paused = pauses_game or _initial_pause_state
	if makes_mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if exclusive and get_tree().current_scene:
		_set_focus_none(get_tree().current_scene)

func _ready() -> void:
	super._ready()
	if visible:
		_open_popup()
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if is_reparenting:
		return
	if _parent_instance and _parent_instance.visible != visible:
		_parent_instance.visible = visible
	if is_visible_in_tree():
		_open_popup()
	elif not visible:
		close()

func _recursive_layer_update(node: Node, last_layer:int) -> void:
	var _children := node.get_children()
	for _child in _children:
		if _child is CanvasLayer:
			_child.layer = last_layer * 2
		_recursive_layer_update(_child, last_layer)

func _enter_tree() -> void:
	if is_reparenting:
		return
	_scene_tree = get_tree()

func _exit_tree() -> void:
	if is_reparenting:
		return
	super._exit_tree()
