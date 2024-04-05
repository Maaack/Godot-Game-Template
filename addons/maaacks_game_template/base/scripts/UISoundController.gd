class_name UISoundController
extends Node
## Controller for managing all UI sounds in a scene from one place.
##
## This node manages all of the UI sounds under the provided node path.
## When attached just below the root node of a scene tree, it will manage
## all of the UI sounds in that scene.

const MAX_DEPTH = 16

@export var root_path : NodePath = ^".."
@export var audio_bus : StringName = &"SFX"
## Continually check any new nodes added to the scene tree.
@export var persistent : bool = true :
	set(value):
		persistent = value
		_update_persistent_signals()

@export_group("Button Sounds")
@export var button_hovered : AudioStream
@export var button_focused : AudioStream
@export var button_pressed : AudioStream

@export_group("TabBar Sounds")
@export var tab_hovered : AudioStream
@export var tab_changed : AudioStream
@export var tab_selected : AudioStream

@export_group("Slider Sounds")
@export var slider_hovered : AudioStream
@export var slider_focused : AudioStream
@export var slider_drag_started : AudioStream
@export var slider_drag_ended : AudioStream

@export_group("LineEdit Sounds")
@export var line_hovered : AudioStream
@export var line_focused : AudioStream
@export var line_text_changed : AudioStream
@export var line_text_submitted : AudioStream
@export var line_text_change_rejected : AudioStream

@onready var root_node : Node = get_node(root_path)

var button_hovered_player : AudioStreamPlayer
var button_focused_player : AudioStreamPlayer
var button_pressed_player : AudioStreamPlayer

var tab_hovered_player : AudioStreamPlayer
var tab_changed_player : AudioStreamPlayer
var tab_selected_player : AudioStreamPlayer

var slider_hovered_player : AudioStreamPlayer
var slider_focused_player : AudioStreamPlayer
var slider_drag_started_player : AudioStreamPlayer
var slider_drag_ended_player : AudioStreamPlayer

var line_hovered_player : AudioStreamPlayer
var line_focused_player : AudioStreamPlayer
var line_text_changed_player : AudioStreamPlayer
var line_text_submitted_player : AudioStreamPlayer
var line_text_change_rejected_player : AudioStreamPlayer

func _update_persistent_signals():
	if not is_inside_tree():
		return
	var tree_node = get_tree()
	if persistent:
		if not tree_node.node_added.is_connected(connect_ui_sounds):
			tree_node.node_added.connect(connect_ui_sounds)
	else:
		if tree_node.node_added.is_connected(connect_ui_sounds):
			tree_node.node_added.disconnect(connect_ui_sounds)

func _build_stream_player(stream : AudioStream, stream_name : String = ""):
	var stream_player : AudioStreamPlayer
	if stream != null:
		stream_player = AudioStreamPlayer.new()
		stream_player.stream = stream
		stream_player.bus = audio_bus
		stream_player.name = stream_name + "AudioStreamPlayer"
		add_child(stream_player)
	return stream_player

func _build_button_stream_players():
	button_hovered_player = _build_stream_player(button_hovered, "ButtonHovered")
	button_focused_player = _build_stream_player(button_focused, "ButtonFocused")
	button_pressed_player = _build_stream_player(button_pressed, "ButtonClicked")

func _build_tab_stream_players():
	tab_hovered_player = _build_stream_player(tab_hovered, "TabHovered")
	tab_changed_player = _build_stream_player(tab_changed, "TabChanged")
	tab_selected_player = _build_stream_player(tab_selected, "TabSelected")

func _build_slider_stream_players():
	slider_hovered_player = _build_stream_player(slider_hovered, "SliderHovered")
	slider_focused_player = _build_stream_player(slider_focused, "SliderFocused")
	slider_drag_started_player = _build_stream_player(slider_drag_started, "SliderDragStarted")
	slider_drag_ended_player = _build_stream_player(slider_drag_ended, "SliderDragEnded")

func _build_line_stream_players():
	line_hovered_player = _build_stream_player(line_hovered, "LineHovered")
	line_focused_player = _build_stream_player(line_focused, "LineFocused")
	line_text_changed_player = _build_stream_player(line_text_changed, "LineTextChanged")
	line_text_submitted_player = _build_stream_player(line_text_submitted, "LineTextSubmitted")
	line_text_change_rejected_player = _build_stream_player(line_text_change_rejected, "LineTextChangeRejected")

func _build_all_stream_players():
	_build_button_stream_players()
	_build_tab_stream_players()
	_build_slider_stream_players()
	_build_line_stream_players()

func _play_stream(stream_player : AudioStreamPlayer):
	if not stream_player.is_inside_tree():
		return
	stream_player.play()

func _tab_event_play_stream(_tab_idx : int, stream_player : AudioStreamPlayer):
	_play_stream(stream_player)

func _slider_drag_ended_play_stream(_value_changed : bool, stream_player : AudioStreamPlayer):
	_play_stream(stream_player)

func _line_event_play_stream(_new_text : String, stream_player : AudioStreamPlayer):
	_play_stream(stream_player)

func _connect_stream_player(node : Node, stream_player : AudioStreamPlayer, signal_name : StringName, callable : Callable) -> void:
	if stream_player != null and not node.is_connected(signal_name, callable.bind(stream_player)):
		node.connect(signal_name, callable.bind(stream_player))

func connect_ui_sounds(node: Node) -> void:
	if node is Button:
		_connect_stream_player(node, button_hovered_player, &"mouse_entered", _play_stream)
		_connect_stream_player(node, button_focused_player, &"focus_entered", _play_stream)
		_connect_stream_player(node, button_pressed_player, &"pressed", _play_stream)
	elif node is TabBar:
		_connect_stream_player(node, tab_hovered_player, &"tab_hovered", _tab_event_play_stream)
		_connect_stream_player(node, tab_changed_player, &"tab_changed", _tab_event_play_stream)
		_connect_stream_player(node, tab_selected_player, &"tab_selected", _tab_event_play_stream)
	elif node is Slider:
		_connect_stream_player(node, slider_hovered_player, &"mouse_entered", _play_stream)
		_connect_stream_player(node, slider_focused_player, &"focus_entered", _play_stream)
		_connect_stream_player(node, slider_drag_started_player, &"drag_started", _play_stream)
		_connect_stream_player(node, slider_drag_ended_player, &"drag_ended", _slider_drag_ended_play_stream)
	elif node is LineEdit:
		_connect_stream_player(node, line_hovered_player, &"mouse_entered", _play_stream)
		_connect_stream_player(node, line_focused_player, &"focus_entered", _play_stream)
		_connect_stream_player(node, line_text_changed_player, &"text_changed", _line_event_play_stream)
		_connect_stream_player(node, line_text_submitted_player, &"text_submitted", _line_event_play_stream)
		_connect_stream_player(node, line_text_change_rejected_player, &"text_change_rejected", _line_event_play_stream)

func _recursive_connect_ui_sounds(current_node: Node, current_depth : int = 0) -> void:
	if current_depth >= MAX_DEPTH:
		return
	for node in current_node.get_children():
		connect_ui_sounds(node)
		_recursive_connect_ui_sounds(node, current_depth + 1)

func _ready() -> void:
	_build_all_stream_players()
	_recursive_connect_ui_sounds(root_node)
	persistent = persistent

func _exit_tree():
	var tree_node = get_tree()
	if tree_node.node_added.is_connected(connect_ui_sounds):
		tree_node.node_added.disconnect(connect_ui_sounds)
