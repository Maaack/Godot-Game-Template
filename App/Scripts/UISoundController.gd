extends Node
class_name UISoundController

const MAX_DEPTH = 16

@export var root_path : NodePath = ^".."
@export var audio_bus : StringName = &"SFX"
@export var persistent : bool = true :
	set(value):
		persistent = value
		_update_persistent_signals()

@export_category("Button Sounds")
@export var button_hover : AudioStream
@export var button_focus : AudioStream
@export var button_click : AudioStream

@export_category("Tab Sounds")
@export var tab_hover : AudioStream
@export var tab_changed : AudioStream
@export var tab_selected : AudioStream

@onready var root_node : Node = get_node(root_path)

var button_hover_player : AudioStreamPlayer
var button_focus_player : AudioStreamPlayer
var button_click_player : AudioStreamPlayer

var tab_hover_player : AudioStreamPlayer
var tab_changed_player : AudioStreamPlayer
var tab_selected_player : AudioStreamPlayer

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

func _build_stream_player(stream: AudioStream):
	var stream_player : AudioStreamPlayer
	if stream != null:
		stream_player = AudioStreamPlayer.new()
		stream_player.stream = stream
		stream_player.bus = audio_bus
		add_child(stream_player)
	return stream_player

func _build_button_stream_players():
	button_hover_player = _build_stream_player(button_hover)
	button_focus_player = _build_stream_player(button_focus)
	button_click_player = _build_stream_player(button_click)

func _build_tab_stream_players():
	tab_hover_player = _build_stream_player(tab_hover)
	tab_changed_player = _build_stream_player(tab_changed)
	tab_selected_player = _build_stream_player(tab_selected)

func _build_all_stream_players():
	_build_button_stream_players()
	_build_tab_stream_players()

func _play_stream(stream_player : AudioStreamPlayer):
	stream_player.play()

func _tab_play_stream(_tab_idx : int, stream_player : AudioStreamPlayer):
	_play_stream(stream_player)

func connect_ui_sounds(node: Node) -> void:
	if node is Button:
		if button_hover_player != null and not node.mouse_entered.is_connected(_play_stream.bind(button_hover_player)):
			node.mouse_entered.connect(_play_stream.bind(button_hover_player))
		if button_focus_player != null and not node.focus_entered.is_connected(_play_stream.bind(button_focus_player)):
			node.focus_entered.connect(_play_stream.bind(button_focus_player))
		if button_click_player != null and not node.pressed.is_connected(_play_stream.bind(button_click_player)):
			node.pressed.connect(_play_stream.bind(button_click_player))
	elif node is TabBar:
		if tab_hover_player != null and not node.tab_hovered.is_connected(_tab_play_stream.bind(tab_hover_player)):
			node.tab_hovered.connect(_tab_play_stream.bind(tab_hover_player))
		if tab_changed_player != null and not node.tab_changed.is_connected(_tab_play_stream.bind(tab_changed_player)):
			node.tab_changed.connect(_tab_play_stream.bind(tab_changed_player))
		if tab_selected_player != null and not node.tab_selected.is_connected(_tab_play_stream.bind(tab_selected_player)):
			node.tab_selected.connect(_tab_play_stream.bind(tab_selected_player))

func _recurive_connect_ui_sounds(current_node: Node, current_depth : int = 0) -> void:
	if current_depth >= MAX_DEPTH:
		return
	for node in current_node.get_children():
		connect_ui_sounds(node)
		_recurive_connect_ui_sounds(node, current_depth + 1)

func _ready() -> void:
	_build_all_stream_players()
	_recurive_connect_ui_sounds(root_node)
	persistent = persistent
