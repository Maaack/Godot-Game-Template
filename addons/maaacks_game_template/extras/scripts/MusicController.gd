class_name MusicController
extends Node
## Controller for music playback across scenes.
##
## This node manages all of the music players under the provided node path.
## The expected use-case is to attach this script to an autoloaded scene,
## but alternatives uses are supported.

const MAX_DEPTH = 16
const MINIMUM_VOLUME_DB = -80
const MAXIMUM_VOLUME_DB = 24

@export var root_path : NodePath = ^".."
@export var audio_bus : StringName = &"Music"
## Continually check any new nodes added to the scene tree.
@export var persistent : bool = true :
	set(value):
		persistent = value
		_update_persistent_signals()

@export_group("Playback")
@export_range(MINIMUM_VOLUME_DB, MAXIMUM_VOLUME_DB) var volume_db : float
@export var empty_streams_stop_player : bool = true

@export_group("Blending")
@export var fade_out_duration : float = 0.0 :
	set(value):
		fade_out_duration = value
		if fade_out_duration < 0:
			fade_out_duration = 0
			
@export var fade_in_duration : float = 0.0 :
	set(value):
		fade_in_duration = value
		if fade_in_duration < 0:
			fade_in_duration = 0

@onready var root_node : Node = get_node(root_path)

var music_stream_player : AudioStreamPlayer
var music_stream : AudioStream

func _update_persistent_signals():
	if not is_inside_tree():
		return
	var tree_node = get_tree()
	if persistent:
		if not tree_node.node_added.is_connected(check_for_music_player):
			tree_node.node_added.connect(check_for_music_player)
	else:
		if tree_node.node_added.is_connected(check_for_music_player):
			tree_node.node_added.disconnect(check_for_music_player)

func fade_out( duration : float = 0.0 ):
	if not is_zero_approx(duration):
		var tween = get_tree().create_tween()
		tween.tween_property(music_stream_player, "volume_db", MINIMUM_VOLUME_DB, duration)
		return tween

func fade_in( duration : float = 0.0 ):
	if not is_zero_approx(duration):
		music_stream_player.volume_db = MINIMUM_VOLUME_DB
		var tween = get_tree().create_tween()
		tween.tween_property(music_stream_player, "volume_db", volume_db, duration)
		return tween

func stop():
	if music_stream_player == null:
		return
	music_stream_player.stop()

func play():
	if music_stream_player == null:
		return
	music_stream_player.volume_db = volume_db
	music_stream_player.play()

func fade_out_and_free( duration : float = 0.0 ):
	if music_stream_player == null:
		return
	var stream_player = music_stream_player
	var tween = fade_out( duration )
	if tween != null:
		await( tween.finished )
	stream_player.queue_free()

func play_and_fade_in( duration : float = 0.0 ):
	if music_stream_player == null:
		return
	music_stream_player.play()
	var tween = fade_in( duration )
	if tween == null:
		music_stream_player.volume_db = volume_db

func _is_matching_stream( stream_player : AudioStreamPlayer ) -> bool:
	if stream_player.bus != audio_bus:
		return false
	if music_stream_player == null:
		return false
	return music_stream_player.stream == stream_player.stream

func reparent_music_player( stream_player : AudioStreamPlayer ):
	stream_player.call_deferred("reparent", self)
	music_stream_player = stream_player

func _blend_in_stream_player( stream_player : AudioStreamPlayer ):
	fade_out_and_free(fade_out_duration)
	reparent_music_player(stream_player)
	play_and_fade_in(fade_in_duration)

func check_for_music_player( node: Node ) -> void:
	if node == music_stream_player : return
	if node is AudioStreamPlayer and node.autoplay:
		if _is_matching_stream(node):
			node.stop()
			node.queue_free()
			if not music_stream_player.playing:
				play()
		else:
			if node.stream == null and not empty_streams_stop_player:
				return
			_blend_in_stream_player(node)

func _recursive_check_for_music_player( current_node: Node, current_depth : int = 0 ) -> void:
	if current_depth >= MAX_DEPTH:
		return
	for node in current_node.get_children():
		check_for_music_player(node)
		_recursive_check_for_music_player(node, current_depth + 1)

func _ready() -> void:
	_recursive_check_for_music_player(root_node)
	persistent = persistent

func _exit_tree():
	var tree_node = get_tree()
	if tree_node.node_added.is_connected(check_for_music_player):
		tree_node.node_added.disconnect(check_for_music_player)
