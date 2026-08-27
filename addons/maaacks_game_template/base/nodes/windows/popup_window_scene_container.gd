@tool
class_name PopupWindowSceneContainer
extends PopupWindowPanel

## Packed scene to load in the body of the window.
@export var packed_scene : PackedScene :
	set(value):
		packed_scene = value
		if is_inside_tree():
			for child in scene_container.get_children():
				child.queue_free()
			if packed_scene:
				instance = packed_scene.instantiate()
				scene_container.add_child(instance)

@onready var scene_container : Container = %SceneContainer

var instance : Node

func _ready() -> void:
	super._ready()
	packed_scene = packed_scene
