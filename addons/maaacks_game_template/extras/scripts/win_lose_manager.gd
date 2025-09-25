extends Node

## Path to a main menu scene.
@export_file("*.tscn") var main_menu_scene : String
## Optional path to an ending scene.
@export_file("*.tscn") var ending_scene : String
## Optional screen to be shown after the game is won.
@export var game_won_scene : PackedScene
## Optional screen to be shown after the game is lost.
@export var game_lost_scene : PackedScene

func _try_connecting_signal_to_node(node : Node, signal_name : String, callable : Callable) -> void:
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func _load_main_menu() -> void:
	SceneLoader.load_scene(main_menu_scene)

func _load_ending() -> void:
	if ending_scene:
		SceneLoader.load_scene(ending_scene)
	else:
		_load_main_menu()

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
	_load_lose_screen_or_reload()

func game_won() -> void:
	_load_win_screen_or_ending()
