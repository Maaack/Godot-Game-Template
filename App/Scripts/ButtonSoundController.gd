extends Node
class_name ButtonSoundController

@export var root_path : NodePath = ^".."
@export var audio_bus : StringName = &"SFX"

@export var button_hover : AudioStream
@export var button_focus : AudioStream
@export var button_click : AudioStream

@onready var root_node : Node = get_node(root_path)

var button_hover_player : AudioStreamPlayer
var button_focus_player : AudioStreamPlayer
var button_click_player : AudioStreamPlayer

func _build_stream_player(stream: AudioStream):
	var stream_player : AudioStreamPlayer
	if stream != null:
		stream_player = AudioStreamPlayer.new()
		stream_player.stream = stream
		stream_player.bus = audio_bus
		add_child(stream_player)
	return stream_player

func _build_stream_players():
	button_hover_player = _build_stream_player(button_hover)
	button_focus_player = _build_stream_player(button_focus)
	button_click_player = _build_stream_player(button_click)

func _play_stream(stream_player : AudioStreamPlayer):
	stream_player.play()

func _ready() -> void:
	_build_stream_players()
	connect_button_sounds(root_node)
	get_tree().node_added.connect(connect_button_sounds)

func connect_button_sounds(current_node: Node) -> void:
	for node in current_node.get_children():
		if node is Button:
			print(node)
			if button_hover_player != null and not node.mouse_entered.is_connected(_play_stream.bind(button_hover_player)):
				node.mouse_entered.connect(_play_stream.bind(button_hover_player))
			if button_focus_player != null and not node.focus_entered.is_connected(_play_stream.bind(button_focus_player)):
				node.focus_entered.connect(_play_stream.bind(button_focus_player))
			if button_click_player != null and not node.pressed.is_connected(_play_stream.bind(button_click_player)):
				node.pressed.connect(_play_stream.bind(button_click_player))
		connect_button_sounds(node)
