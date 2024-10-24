extends Control

@export var win_scene : PackedScene
@export var lose_scene : PackedScene
@export var level_complete_scene : PackedScene

var current_level

func _ready():
	InGameMenuController.scene_tree = get_tree()

func _on_level_lost():
	InGameMenuController.open_menu(lose_scene, get_viewport())

func _load_next_level():
	$LevelLoader.advance_and_load_level()

func _reload_level():
	$LevelLoader.reload_level()

func _on_level_won():
	if $LevelLoader.is_on_last_level():
		InGameMenuController.open_menu(win_scene, get_viewport())
	else:
		InGameMenuController.open_menu(level_complete_scene, get_viewport())
		InGameMenuController.current_menu.continue_pressed.connect(_load_next_level)
		InGameMenuController.current_menu.restart_pressed.connect(_reload_level)

func _try_connecting_signal_to_node(node : Node, signal_name : String, callable : Callable):
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func _try_connecting_signal_to_level(signal_name : String, callable : Callable):
	_try_connecting_signal_to_node(current_level, signal_name, callable)

func _on_level_loader_level_loaded():
	current_level = $LevelLoader.current_level
	await current_level.ready
	_try_connecting_signal_to_level(&"level_won", _on_level_won)
	_try_connecting_signal_to_level(&"level_lost", _on_level_lost)
	_try_connecting_signal_to_level(&"level_skipped", _load_next_level)
	$LevelLoadingScreen.close()

func _on_level_loader_levels_finished():
	InGameMenuController.open_menu(win_scene, get_viewport())

func _on_level_loader_level_load_started():
	$LevelLoadingScreen.reset()
