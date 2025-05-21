@tool
class_name LevelLoader
extends Node
## Loads scenes into a container.

signal level_load_started
signal level_loaded
signal level_ready

## Container where the level instance will be added.
@export var level_container : Node
## Loads a level on start.
@export var auto_load : bool = false
@export var current_level_path : String
@export_group("Debugging")
@export var force_level : String
@export var current_level : Node

var is_loading : bool = false

func get_current_level_path() -> String:
	return current_level_path if force_level.is_empty() else force_level

func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_level(level_path : String = get_current_level_path()):
	if is_loading : return
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	is_loading = true
	current_level_path = level_path
	SceneLoader.load_scene(level_path, true)
	level_load_started.emit()
	await SceneLoader.scene_loaded
	is_loading = false
	current_level = _attach_level(SceneLoader.get_resource())
	level_loaded.emit()
	await current_level.ready
	level_ready.emit()

func reload_level():
	load_level()

func _ready():
	if auto_load:
		load_level()
