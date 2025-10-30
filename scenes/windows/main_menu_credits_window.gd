@tool
extends "res://addons/maaacks_game_template/base/nodes/windows/overlaid_window_scene_container.gd"

func _ready() -> void:
	super._ready()
	if instance and instance.has_signal(&"end_reached"):
		instance.connect(&"end_reached", close)
