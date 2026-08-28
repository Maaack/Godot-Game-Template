@tool
class_name PopupWindowPanel
extends WindowPanel

## If true, opening the window will pause the game if it is not already.
## Closing the window will return the paused flag to its original state.
@export var pauses_game : bool = false :
	set(value):
		pauses_game = value
		if pauses_game:
			process_mode = PROCESS_MODE_ALWAYS
		else:
			process_mode = PROCESS_MODE_INHERIT
## If true, opening the window will make the mouse visible if it hidden.
@export var makes_mouse_visible : bool = true
## If true, opening the window will grab and remove focus from all other control 
## nodes currently visible in the scene. Closing the window will return the focus
## flag to its original state on all the affected nodes.
@export var exclusive : bool = true
## Optional packed scene that will serve as the parent of the window when opened.
## This can be used for a CanvasLayer or background element.
@export var parent_scene : PackedScene

@onready var _original_size := size

var _initial_pause_state : bool = false
var _initial_mouse_mode : Input.MouseMode
var _initial_focus_control
var _initial_node_focus_modes : Dictionary
var _initial_tab_focus_modes : Dictionary
var _scene_tree : SceneTree 
var _parent_instance : Node
var _original_parent : Node
var is_reparenting : bool = false

func _ready() -> void:
	super._ready()
	if is_visible_in_tree():
		await _popup_open_coroutine()

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
	if is_reparenting: 
		return
	if not is_opened:
		return
	if pauses_game:
		_scene_tree.paused = _initial_pause_state
	Input.set_mouse_mode(_initial_mouse_mode)
	_set_focus_initial()
	if is_instance_valid(_initial_focus_control) and _initial_focus_control.is_inside_tree():
		_initial_focus_control.grab_focus()
	await _revert_parent_coroutine()
	super.close()

func _add_parent_instance_coroutine() -> void:
	var _canvas_layer_node = get_canvas_layer_node()
	await draw
	if size != _original_size:
		await resized
	_original_size = size
	_parent_instance = parent_scene.instantiate()
	_parent_instance.name = "%s%s" % [name, _parent_instance.name] 
	add_sibling.call_deferred(_parent_instance)
	await _parent_instance.ready
	if _parent_instance is CanvasLayer:
		var _next_layer = 1
		if _canvas_layer_node:
			_next_layer = _canvas_layer_node.layer * 2
		_parent_instance.layer = _next_layer

func _reparent_coroutine() -> void:
	is_reparenting = true
	_original_parent = get_parent()
	reparent.call_deferred(_parent_instance)
	await tree_entered
	is_reparenting = false

func _revert_parent_coroutine() -> void:
	if not _parent_instance:
		return
	is_reparenting = true
	reparent.call_deferred(_original_parent)
	await tree_entered
	is_reparenting = false
	_parent_instance.queue_free()

func _setup_parent_instance_coroutine():
	if Engine.is_editor_hint():
		return
	if _scene_tree.current_scene and _scene_tree.current_scene == self:
		return
	if is_instance_valid(_parent_instance):
		return
	if not parent_scene is PackedScene:
		return
	await _add_parent_instance_coroutine()
	await _reparent_coroutine()

func _popup_open_coroutine():
	if Engine.is_editor_hint():
		return
	_initial_mouse_mode = Input.get_mouse_mode()
	_initial_focus_control = get_viewport().gui_get_focus_owner()
	if _initial_focus_control and get_tree().current_scene and get_tree().current_scene != self:
		_initial_focus_control.release_focus()
	if exclusive and get_tree().current_scene and get_tree().current_scene != self:
		_set_focus_none(get_tree().current_scene)
	await _setup_parent_instance_coroutine()
	if _scene_tree:
		_initial_pause_state = _scene_tree.paused
		_scene_tree.paused = pauses_game or _initial_pause_state
	if makes_mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func open():
	if is_opened:
		return
	super.open()
	await _popup_open_coroutine()

func _on_visibility_changed() -> void:
	if is_reparenting:
		return
	super._on_visibility_changed()
	if _parent_instance and _parent_instance.visible != visible:
		_parent_instance.visible = visible

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
