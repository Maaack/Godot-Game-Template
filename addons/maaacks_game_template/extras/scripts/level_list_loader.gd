@tool
class_name LevelListLoader
extends SceneLister
## Extends [SceneLister] to manage level advancement through [GameStateExample].

signal level_load_started
signal level_loaded
signal levels_finished

## Container where the level instance will be added.
@export var level_container : Node

var current_level : Node

func get_level_file(level_id : int):
	if files.is_empty():
		push_error("levels list is empty")
		return
	if level_id >= files.size():
		push_error("level_id is out of bounds of the levels list")
		level_id = files.size() - 1
	return files[level_id]

func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_level(level_id : int):
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	var level_file = get_level_file(level_id)
	if level_file == null:
		levels_finished.emit()
		return
	SceneLoader.load_scene(level_file, true)
	level_load_started.emit()
	await SceneLoader.scene_loaded
	current_level = _attach_level(SceneLoader.get_resource())
	level_loaded.emit()

func _ready():
	if Engine.is_editor_hint():
		# Text files get a `.remap` extension added on export.
		_refresh_files()
