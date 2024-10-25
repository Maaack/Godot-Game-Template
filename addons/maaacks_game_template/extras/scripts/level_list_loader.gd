@tool
class_name LevelListLoader
extends SceneLister
## Extends [SceneLister] to manage level advancement through [GameLevelLog].

signal level_load_started
signal level_loaded
signal levels_finished

## Container where the level instance will be added.
@export var level_container : Node
## Loads a level on start.
@export var auto_load : bool = true
@export_group("Debugging")
@export var force_level : int = -1

var current_level : Node

func get_current_level_id() -> int:
	return GameLevelLog.get_current_level() if force_level == -1 else force_level

func get_level_file(level_id : int = get_current_level_id()):
	if files.is_empty():
		push_error("levels list is empty")
		return
	if level_id >= files.size():
		push_error("level_id is out of bounds of the levels list")
		level_id = files.size() - 1
	return files[level_id]

func is_on_last_level():
	return get_current_level_id() + 1 >= files.size()

func advance_level() -> bool:
	var level_id : int = get_current_level_id()
	level_id += 1
	if level_id >= files.size():
		emit_signal("levels_finished")
		level_id = files.size() - 1
		return false
	GameLevelLog.level_reached(level_id)
	return true

func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_level(level_id : int = get_current_level_id()):
	GameLevelLog.set_current_level(level_id)
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

func reload_level():
	load_level()

func advance_and_load_level():
	if advance_level():
		load_level()

func _ready():
	if Engine.is_editor_hint():
		# Text files get a `.remap` extension added on export.
		_refresh_files()
	if auto_load:
		load_level()
