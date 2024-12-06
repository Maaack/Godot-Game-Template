extends Node

signal level_won
signal level_lost

var level_state : LevelStateExample

func _on_lose_button_pressed():
	level_lost.emit()

func _on_win_button_pressed():
	level_won.emit()

func _ready():
	GameStateExample.current_level = scene_file_path
	level_state = GameStateExample.get_current_level_state()
	%ColorPickerButton.color = level_state.color
	%ColorPickerButton.color_changed.emit(level_state.color)

func _on_color_picker_button_color_changed(color):
	%ColorPickerButton.color = color
	%BackgroundColor.color = color
	level_state.color = color
	GlobalState.save()
