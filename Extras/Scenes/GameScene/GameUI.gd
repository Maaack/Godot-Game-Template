extends Control

@export var win_scene : PackedScene
@export var lose_scene : PackedScene
@onready var action_names = AppSettings.get_filtered_action_names()

func _get_inputs_as_string():
	var all_inputs : String = ""
	var is_first : bool = true
	for action_name in action_names:
			if Input.is_action_pressed(action_name):
				if is_first:
					is_first = false
					all_inputs += action_name
				else:
					all_inputs += " + " + action_name
	return all_inputs

func _process(_delta):
	if Input.is_anything_pressed():
		$Label.text = _get_inputs_as_string()
	else:
		$Label.text = ""

func _ready():
	InGameMenuController.scene_tree = get_tree()

func _on_level_lost():
	InGameMenuController.open_menu(lose_scene, get_viewport())

func _on_level_won():
	$LevelLoader.advance_and_load_level()

func _on_level_loader_level_loaded():
	if $LevelLoader.current_level.has_signal("level_won"):
		$LevelLoader.current_level.level_won.connect(_on_level_won)
	if $LevelLoader.current_level.has_signal("level_lost"):
		$LevelLoader.current_level.level_lost.connect(_on_level_lost)

func _on_level_loader_levels_finished():
	InGameMenuController.open_menu(win_scene, get_viewport())
