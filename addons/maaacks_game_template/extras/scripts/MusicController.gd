class_name MusicController
extends Node
## Controller for music playback across scenes.
##
## This node manages all of the music players under the provided node path.
## The expected use-case is to attach this script to an autoloaded scene,
## but alternatives use-cases are supported.

const MAX_DEPTH = 16

@export var root_path : NodePath = ^".."
@export var audio_bus : StringName = &"Music"

## Continually check any new nodes added to the scene tree.
@export var persistent : bool = true :
	set(value):
		persistent = value
		_update_persistent_signals()

@export var empty_streams_stop_player : bool = true

@onready var root_node : Node = get_node(root_path)

var music_stream_player : AudioStreamPlayer

func _update_persistent_signals():
	if not is_inside_tree():
		return
	var tree_node = get_tree()
	if persistent:
		if not tree_node.node_added.is_connected(intercept_music_player):
			tree_node.node_added.connect(intercept_music_player)
	else:
		if tree_node.node_added.is_connected(intercept_music_player):
			tree_node.node_added.disconnect(intercept_music_player)

func _build_stream_player(stream : AudioStream, stream_name : String = "") -> AudioStreamPlayer:
	var stream_player : AudioStreamPlayer
	if stream != null:
		stream_player = AudioStreamPlayer.new()
		stream_player.stream = stream
		stream_player.bus = audio_bus
		stream_player.finished.connect(func (): stream_player.queue_free())
		if not name.is_empty():
			stream_player.name = stream_name
		add_child(stream_player)
		
	return stream_player

func play_stream(stream : AudioStream, stream_name : String = ""):
	if music_stream_player == null:
		music_stream_player = _build_stream_player(stream, stream_name)
	if stream == null and not empty_streams_stop_player:
		return
	if music_stream_player.stream != stream:
		music_stream_player.stop()
		music_stream_player.stream = stream
	if not music_stream_player.playing:
		music_stream_player.play()

func intercept_music_player(node: Node) -> void:
	if node is AudioStreamPlayer:
		if node.bus == audio_bus and node.autoplay:
			play_stream(node.stream, node.name)
			node.autoplay = false
			node.stop()

func _recursive_intercept_music_player(current_node: Node, current_depth : int = 0) -> void:
	if current_depth >= MAX_DEPTH:
		return
	for node in current_node.get_children():
		intercept_music_player(node)
		_recursive_intercept_music_player(node, current_depth + 1)

func _ready() -> void:
	_recursive_intercept_music_player(root_node)
	persistent = persistent

func _exit_tree():
	var tree_node = get_tree()
	if tree_node.node_added.is_connected(intercept_music_player):
		tree_node.node_added.disconnect(intercept_music_player)
