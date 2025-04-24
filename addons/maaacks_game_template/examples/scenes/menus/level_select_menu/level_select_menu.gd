extends Control

## Loads a simple ItemList node within a margin container. SceneLister updates
## the available scenes in the directory provided. Activating a level will update
## the GameState's current_level, and emit a signal. The main menu node will trigger
## a load action from that signal.

@onready var level_buttons_container: ItemList = %LevelButtonsContainer
@onready var scene_lister: SceneLister = $SceneLister

signal level_selected
		
func _ready() -> void:
	add_levels_to_container()
	
## A fresh level list is propgated into the ItemList, and the file names are cleaned
func add_levels_to_container() -> void:
	level_buttons_container.clear()
	var max_level_reached := GameStateExample.get_max_level_reached()
	var level_iter := 0
	for file_path in scene_lister.files:
		if level_iter > max_level_reached : break
		level_iter += 1
		var file_name := file_path.get_file()  # e.g., "level_1.tscn"
		file_name = file_name.trim_suffix(".tscn")  # Remove the ".tscn" extension
		file_name = file_name.replace("_", " ")  # Replace underscores with spaces
		file_name = file_name.capitalize()  # Convert to proper case
		var button_name := str(file_name)
		level_buttons_container.add_item(button_name)

func _on_level_buttons_container_item_activated(index: int) -> void:
	GameStateExample.set_current_level(index)
	level_selected.emit()
