class_name LevelListManager
extends Node
## Manager of level progress and the result screens between them.
##
## A helper script to assign to a node in a scene.
## It works with a level list loader and a loading screen
## to advance levels and open menus when players win or lose. 

## Required reference to a level list loader in the scene.
@export var level_list_loader : LevelListLoader
## Required path to a main menu scene.
@export_file("*.tscn") var main_menu_scene : String
## Optional path to an ending scene.
@export_file("*.tscn") var ending_scene : String
@export_group("Screens")
## Optional reference to a loading screen in the scene.
@export var level_loading_screen : LoadingScreen
## Optional win screen to be shown after the last level is won.
@export var game_won_scene : PackedScene
## Optional lose screen to be shown after the level is lost.
@export var level_lost_scene : PackedScene
## Optional level compete screen to be shown after the level is won.
@export var level_won_scene : PackedScene

## Reference to the current level node.
var current_level

func _try_connecting_signal_to_node(node : Node, signal_name : String, callable : Callable):
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func _try_connecting_signal_to_level(signal_name : String, callable : Callable):
	_try_connecting_signal_to_node(current_level, signal_name, callable)

func _load_main_menu():
	SceneLoader.load_scene(main_menu_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _advance_and_load_main_menu():
	level_list_loader.advance_level()
	_load_main_menu()

func _load_ending():
	if ending_scene:
		SceneLoader.load_scene(ending_scene)
	else:
		_load_main_menu()

func _on_level_lost():
	if level_lost_scene:
		var instance = level_lost_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_reload_level()

func _advance_and_reload():
	var _current_level_id = level_list_loader.get_current_level_id()
	level_list_loader.advance_level()
	level_list_loader.load_level(_current_level_id)

func _load_next_level():
	level_list_loader.advance_and_load_level()

func _reload_level():
	level_list_loader.reload_level()

func _load_win_screen_or_ending():
	if game_won_scene:
		var instance = game_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"continue_pressed", _load_ending)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_load_ending()

func _load_level_complete_screen_or_next_level():
	if level_won_scene:
		var instance = level_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"continue_pressed", _load_next_level)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _advance_and_reload)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _advance_and_load_main_menu)
	else:
		_load_next_level()

func _on_level_won():
	if level_list_loader.is_on_last_level():
		_load_win_screen_or_ending()
	else:
		_load_level_complete_screen_or_next_level()

func _connect_level_signals():
	_try_connecting_signal_to_level(&"level_won", _on_level_won)
	_try_connecting_signal_to_level(&"level_lost", _on_level_lost)
	_try_connecting_signal_to_level(&"level_skipped", _load_next_level)

func _on_level_loader_level_loaded():
	current_level = level_list_loader.current_level
	await current_level.ready
	_connect_level_signals()
	if level_loading_screen:
		level_loading_screen.close()

func _on_level_loader_levels_finished():
	_load_win_screen_or_ending()

func _on_level_loader_level_load_started():
	if level_loading_screen:
		level_loading_screen.reset()

func _ready():
	level_list_loader.level_loaded.connect(_on_level_loader_level_loaded)
	level_list_loader.levels_finished.connect(_on_level_loader_levels_finished)
	level_list_loader.level_load_started.connect(_on_level_loader_level_load_started)
