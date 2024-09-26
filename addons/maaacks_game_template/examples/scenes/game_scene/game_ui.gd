extends Control

@export var win_scene : PackedScene
@export var lose_scene : PackedScene

var current_level

func _ready():
	InGameMenuController.scene_tree = get_tree()

func _on_level_lost():
	InGameMenuController.open_menu(lose_scene, get_viewport())

func _on_level_won():
	$LevelLoader.advance_and_load_level()

func _on_level_loader_level_loaded():
	current_level = $LevelLoader.current_level
	await current_level.ready
	if current_level.has_signal("level_won"):
		current_level.level_won.connect(_on_level_won)
	if current_level.has_signal("level_lost"):
		current_level.level_lost.connect(_on_level_lost)
	$LoadingScreen.close()

func _on_level_loader_levels_finished():
	InGameMenuController.open_menu(win_scene, get_viewport())

func _on_level_loader_level_load_started():
	$LoadingScreen.reset()
