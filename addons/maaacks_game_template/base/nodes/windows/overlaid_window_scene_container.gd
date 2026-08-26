@tool
class_name PopupWindowPanelContainer
extends PopupWindowPanel

var instance : Node
@onready var scene_container : Container = %SceneContainer

@export var packed_scene : PackedScene :
	set(value):
		packed_scene = value
		if is_inside_tree():
			for child in scene_container.get_children():
				child.queue_free()
			if packed_scene:
				instance = packed_scene.instantiate()
				scene_container.add_child(instance)

func _setup() -> void:
	super._setup()
	packed_scene = packed_scene
