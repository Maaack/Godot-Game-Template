@tool
class_name LevelLoader
extends Node
## Loads scenes into a container.

signal level_load_started
signal level_loaded
signal level_ready

## Container where the level instance will be added.
@export var level_container : Node
## Optional reference to a loading screen in the scene.
## Requires Maaack's Scene Loader.
@export var level_loading_screen : Node
@export_group("Debugging")
@export var current_level : Node

## If Maaack's Scene Loader is installed, then it will be used to change scenes.
@onready var scene_loader_node = get_tree().root.get_node_or_null(^"SceneLoader")

var current_level_path : String
var is_loading : bool = false

func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_level(level_path : String):
	if is_loading : return
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	current_level_path = level_path
	if scene_loader_node:
		is_loading = true
		scene_loader_node.load_scene(level_path, true)
		if level_loading_screen:
			level_loading_screen.reset()
		level_load_started.emit()
		await scene_loader_node.scene_loaded
		is_loading = false
		current_level = _attach_level(scene_loader_node.get_resource())
		if level_loading_screen:
			level_loading_screen.close()
	else:
		var level_scene = load(level_path)
		current_level = _attach_level(level_scene)
	level_loaded.emit()
	await current_level.ready
	level_ready.emit()
