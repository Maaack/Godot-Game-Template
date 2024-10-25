extends Node

@export var level_list_loader : LevelListLoader
@export var level_loading_screen : LoadingScreen
@export var win_scene : PackedScene
@export var lose_scene : PackedScene
@export var level_complete_scene : PackedScene
@export_file("*.tscn") var main_menu_scene : String
@export_file("*.tscn") var end_credits_scene : String

var current_level

func _try_connecting_signal_to_node(node : Node, signal_name : String, callable : Callable):
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func _try_connecting_signal_to_level(signal_name : String, callable : Callable):
	_try_connecting_signal_to_node(current_level, signal_name, callable)

func _try_connecting_signal_to_current_menu(signal_name : String, callable : Callable):
	_try_connecting_signal_to_node(InGameMenuController.current_menu, signal_name, callable)

func _load_main_menu():
	InGameMenuController.close_menu()
	SceneLoader.load_scene(main_menu_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _advance_and_load_main_menu():
	level_list_loader.advance_level()
	_load_main_menu()

func _load_end_credits():
	InGameMenuController.close_menu()
	SceneLoader.load_scene(end_credits_scene)

func _on_level_lost():
	if lose_scene:
		InGameMenuController.open_menu(lose_scene, get_viewport())
		_try_connecting_signal_to_current_menu(&"restart_pressed", _reload_level)
		_try_connecting_signal_to_current_menu(&"main_menu_pressed", _load_main_menu)
	else:
		_reload_level()

func _advance_and_reload():
	var _current_level_id = level_list_loader.get_current_level_id()
	level_list_loader.advance_level()
	level_list_loader.load_level(_current_level_id)

func _load_next_level():
	InGameMenuController.close_menu()
	level_list_loader.advance_and_load_level()

func _reload_level():
	InGameMenuController.close_menu()
	level_list_loader.reload_level()

func _on_level_won():
	if level_list_loader.is_on_last_level():
		if win_scene:
			InGameMenuController.open_menu(win_scene, get_viewport())
			_try_connecting_signal_to_current_menu(&"continue_pressed", _load_end_credits)
			_try_connecting_signal_to_current_menu(&"restart_pressed", _reload_level)
			_try_connecting_signal_to_current_menu(&"main_menu_pressed", _load_main_menu)
		else:
			_load_end_credits()
	else:
		if level_complete_scene:
			InGameMenuController.open_menu(level_complete_scene, get_viewport())
			_try_connecting_signal_to_current_menu(&"continue_pressed", _load_next_level)
			_try_connecting_signal_to_current_menu(&"restart_pressed", _advance_and_reload)
			_try_connecting_signal_to_current_menu(&"main_menu_pressed", _advance_and_load_main_menu)
		else:
			_load_next_level()

func _on_level_loader_level_loaded():
	current_level = level_list_loader.current_level
	await current_level.ready
	_try_connecting_signal_to_level(&"level_won", _on_level_won)
	_try_connecting_signal_to_level(&"level_lost", _on_level_lost)
	_try_connecting_signal_to_level(&"level_skipped", _load_next_level)
	level_loading_screen.close()

func _on_level_loader_levels_finished():
	InGameMenuController.open_menu(win_scene, get_viewport())

func _on_level_loader_level_load_started():
	level_loading_screen.reset()

func _ready():
	InGameMenuController.scene_tree = get_tree()
	level_list_loader.level_loaded.connect(_on_level_loader_level_loaded)
	level_list_loader.levels_finished.connect(_on_level_loader_levels_finished)
	level_list_loader.level_load_started.connect(_on_level_loader_level_load_started)
