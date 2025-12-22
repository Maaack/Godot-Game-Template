extends Node

## Path to a main menu scene.
## Will attempt to read from AppConfig if left empty.
@export_file("*.tscn") var main_menu_scene_path : String
## Optional path to an ending scene.
## Will attempt to read from AppConfig if left empty.
@export_file("*.tscn") var ending_scene_path : String
## Optional screen to be shown after the game is won.
@export var game_won_scene : PackedScene
## Optional screen to be shown after the game is lost.
@export var game_lost_scene : PackedScene

var has_lost_game : bool = false
var has_won_game : bool = false

func _try_connecting_signal_to_node(node : Node, signal_name : String, callable : Callable) -> void:
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func get_main_menu_scene_path() -> String:
	if main_menu_scene_path.is_empty():
		return AppConfig.main_menu_scene_path
	return main_menu_scene_path

func _load_main_menu() -> void:
	SceneLoader.load_scene(get_main_menu_scene_path())

func get_ending_scene_path() -> String:
	if ending_scene_path.is_empty():
		return AppConfig.ending_scene_path
	return ending_scene_path

func _load_ending() -> void:
	if get_ending_scene_path().is_empty():
		_load_main_menu()
	else:
		SceneLoader.load_scene(get_ending_scene_path())

func _load_lose_screen_or_reload() -> void:
	if game_lost_scene:
		var instance = game_lost_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_reload_level()

func _reload_level() -> void:
	SceneLoader.reload_current_scene()

func _load_win_screen_or_ending() -> void:
	if game_won_scene:
		var instance = game_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"continue_pressed", _load_ending)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_load_ending()

func game_lost() -> void:
	if has_won_game or has_lost_game: return
	has_lost_game = true
	_load_lose_screen_or_reload()

func game_won() -> void:
	if has_won_game or has_lost_game: return
	has_won_game = true
	_load_win_screen_or_ending()
