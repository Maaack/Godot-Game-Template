class_name MusicController
extends Node
## Controller for music playback across scenes.
##
## This node persistently checks for stream players added to the scene tree.
## It detects stream players that match the audio bus and have autoplay on.
## It then reparents the stream players to itself, and handles blending.
## The expected use-case is to attach this script to an autoloaded scene.

const MAX_DEPTH = 16
const MINIMUM_VOLUME_DB = -80

## Detect stream players with matching audio bus.
@export var audio_bus : StringName = &"Music"

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

@export var blend_volume_duration : float = 0.0 :
	set(value):
		blend_volume_duration = value
		if blend_volume_duration < 0:
			blend_volume_duration = 0

## Matched stream players with no stream set will stop current playback.
@export var empty_streams_stop_player : bool = true

var music_stream_player : AudioStreamPlayer

func fade_out( duration : float = 0.0 ):
	if not is_zero_approx(duration):
		var tween = get_tree().create_tween()
		tween.tween_property(music_stream_player, "volume_db", MINIMUM_VOLUME_DB, duration)
		return tween

func fade_in( duration : float = 0.0 ):
	if not is_zero_approx(duration):
		var target_volume_db = music_stream_player.volume_db
		music_stream_player.volume_db = MINIMUM_VOLUME_DB
		var tween = get_tree().create_tween()
		tween.tween_property(music_stream_player, "volume_db", target_volume_db, duration)
		return tween

func blend_to( target_volume_db : float, duration : float = 0.0 ):
	if not is_zero_approx(duration):
		var tween = get_tree().create_tween()
		tween.tween_property(music_stream_player, "volume_db", target_volume_db, duration)
		return tween
	music_stream_player.volume_db = target_volume_db

func stop():
	if music_stream_player == null:
		return
	music_stream_player.stop()

func play():
	if music_stream_player == null:
		return
	music_stream_player.play()

func _fade_out_and_free():
	if music_stream_player == null:
		return
	var stream_player = music_stream_player
	var tween = fade_out( fade_out_duration )
	if tween != null:
		await( tween.finished )
	stream_player.queue_free()

func _play_and_fade_in():
	if music_stream_player == null:
		return
	music_stream_player.play()
	fade_in( fade_in_duration )

func _is_matching_stream( stream_player : AudioStreamPlayer ) -> bool:
	if stream_player.bus != audio_bus:
		return false
	if music_stream_player == null:
		return false
	return music_stream_player.stream == stream_player.stream

func _reparent_music_player( stream_player : AudioStreamPlayer ):
	stream_player.call_deferred("reparent", self)
	music_stream_player = stream_player

func _blend_in_stream_player( stream_player : AudioStreamPlayer ):
	_fade_out_and_free()
	_reparent_music_player(stream_player)
	_play_and_fade_in()

func check_for_music_player( node: Node ) -> void:
	if node == music_stream_player : return
	if not (node is AudioStreamPlayer and node.autoplay) : return
	if _is_matching_stream(node):
		blend_to(node.volume_db, blend_volume_duration)
		node.stop()
		node.queue_free()
		if not music_stream_player.playing:
			play()
	else:
		if node.stream == null and not empty_streams_stop_player:
			return
		_blend_in_stream_player(node)

func _ready() -> void:
	var tree_node = get_tree()
	if not tree_node.node_added.is_connected(check_for_music_player):
		tree_node.node_added.connect(check_for_music_player)

func _exit_tree():
	var tree_node = get_tree()
	if tree_node.node_added.is_connected(check_for_music_player):
		tree_node.node_added.disconnect(check_for_music_player)
