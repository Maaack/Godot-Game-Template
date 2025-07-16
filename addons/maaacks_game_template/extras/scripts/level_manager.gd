class_name LevelManager
extends Node
## Manage level changes in games.
##
## A helper script to assign to a node in a scene.
## It works with a level loader and can open menus when players win or lose.
## It can either be assigned a starting level path or a scene lister.
## It can detect signals from levels to change levels in an open-world.
## With a scene lister, it will instead traverse through levels linearly.

## Required reference to a level loader in the scene.
@export var level_loader : LevelLoader
## Optional path to a starting level scene.
## Required if there is no scene lister.
@export_file var starting_level_path : String
## Optional reference to a scene lister in the scene.
## Required if there is no starting level path.
@export var scene_lister : SceneLister
## Whether to load the starting level when ready.
@export var auto_load : bool = true
@export_group("Scenes")
## Path to a main menu scene.
@export_file("*.tscn") var main_menu_scene : String
## Optional path to an ending scene.
@export_file("*.tscn") var ending_scene : String
## Optional screen to be shown after the game is won.
@export var game_won_scene : PackedScene
## Optional screen to be shown after the level is lost.
@export var level_lost_scene : PackedScene
## Optional screen to be shown after the level is won.
@export var level_won_scene : PackedScene
@export_group("Debugging")
## Loads a level on start.
@export_file("*.tscn") var force_level_path : String = ""

## Reference to the current level node.
var current_level : Node
var current_level_path : String :
	set = set_current_level_path

func set_current_level_path(value : String) -> void:
	current_level_path = value

var next_level_path : String : 
	set = set_next_level_path
	
func set_next_level_path(value : String) -> void:
	next_level_path = value

func _try_connecting_signal_to_node(node : Node, signal_name : String, callable : Callable) -> void:
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func _try_connecting_signal_to_level(signal_name : String, callable : Callable) -> void:
	_try_connecting_signal_to_node(current_level, signal_name, callable)

func _load_main_menu() -> void:
	SceneLoader.load_scene(main_menu_scene)

func _find_in_scene_lister(level_path : String) -> int:
	if not scene_lister: return -1
	return scene_lister.files.find(level_path)

func has_next_level() -> bool:
	if scene_lister:
		var current_level_id = _find_in_scene_lister(current_level_path)
		return current_level_id < scene_lister.files.size() - 1
	return (not next_level_path.is_empty()) and next_level_path != current_level_path

func is_on_last_level() -> bool:
	return not has_next_level()

func _advance_level() -> bool:
	if is_on_last_level(): return false
	var current_level_id := _find_in_scene_lister(current_level_path)
	if current_level_id > -1:
		current_level_id += 1
		current_level_path = scene_lister.files[current_level_id]
		return true
	current_level_path = next_level_path
	next_level_path = ""
	return true

func _advance_and_load_main_menu() -> void:
	_advance_level()
	_load_main_menu()

func _load_ending() -> void:
	if ending_scene:
		SceneLoader.load_scene(ending_scene)
	else:
		_load_main_menu()

func _on_level_lost() -> void:
	if level_lost_scene:
		var instance = level_lost_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_reload_level()

func get_current_level_path() -> String:
	if current_level_path.is_empty():
		current_level_path = starting_level_path
		if scene_lister:
			current_level_path = scene_lister.files.front()
	return current_level_path if force_level_path.is_empty() else force_level_path

func load_current_level() -> void:
	level_loader.load_level(get_current_level_path())

func _advance_and_reload_level() -> void:
	var _prior_level_path = current_level_path
	_advance_level()
	current_level_path = _prior_level_path
	load_current_level()

func _load_next_level() -> void:
	_advance_level()
	load_current_level()

func _reload_level() -> void:
	load_current_level()

func _load_win_screen_or_ending() -> void:
	if game_won_scene:
		var instance = game_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"continue_pressed", _load_ending)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_load_ending()

func _load_level_won_screen_or_next_level() -> void:
	if level_won_scene:
		var instance = level_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"continue_pressed", _load_next_level)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _advance_and_reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _advance_and_load_main_menu)
	else:
		_load_next_level()

func _on_level_won():
	if is_on_last_level():
		_load_win_screen_or_ending()
	else:
		_load_level_won_screen_or_next_level()

func _on_level_won_and_changed(next_level : String):
	next_level_path = next_level
	_on_level_won()

func _on_level_changed(next_level : String):
	next_level_path = next_level
	_load_next_level()

func _connect_level_signals() -> void:
	_try_connecting_signal_to_level(&"level_lost", _on_level_lost)
	_try_connecting_signal_to_level(&"level_won", _on_level_won)
	_try_connecting_signal_to_level(&"level_won_and_changed", _on_level_won_and_changed)
	_try_connecting_signal_to_level(&"level_changed", _on_level_changed)
	_try_connecting_signal_to_level(&"level_passed", _load_next_level)
	_try_connecting_signal_to_level(&"next_level_set", set_next_level_path)

func _on_level_loader_level_loaded() -> void:
	current_level = level_loader.current_level
	await current_level.ready
	_connect_level_signals()

func _on_level_loader_level_load_started() -> void:
	pass

func _on_level_loader_level_ready() -> void:
	pass

func _auto_load() -> void:
	if auto_load:
		load_current_level()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	level_loader.level_loaded.connect(_on_level_loader_level_loaded)
	level_loader.level_ready.connect(_on_level_loader_level_ready)
	level_loader.level_load_started.connect(_on_level_loader_level_load_started)
	_auto_load()
