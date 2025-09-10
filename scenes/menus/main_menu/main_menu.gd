extends MainMenu

@export var level_select_packed_scene: PackedScene
@export var confirm_new_game : bool = true

var level_select_scene : Node

@onready var continue_game_button = %ContinueGameButton
@onready var level_select_button = %LevelSelectButton
@onready var level_select_container = %LevelSelectContainer

func load_game_scene() -> void:
	GameState.start_game()
	super.load_game_scene()

func new_game() -> void:
	if confirm_new_game and GameState.has_game_state():
		%NewGameConfirmationDialog.popup_centered()
	else:
		GameState.reset()
		load_game_scene()

func _add_level_select_if_set() -> void: 
	if level_select_packed_scene == null: return
	if GameState.get_levels_reached() <= 1 : return
	level_select_scene = level_select_packed_scene.instantiate()
	level_select_scene.hide()
	level_select_container.show()
	level_select_container.call_deferred("add_child", level_select_scene)
	if level_select_scene.has_signal("level_selected"):
		level_select_scene.connect("level_selected", load_game_scene)
	level_select_button.show()

func _show_continue_if_set() -> void:
	if GameState.has_game_state():
		continue_game_button.show()

func _ready() -> void:
	super._ready()
	_add_level_select_if_set()
	_show_continue_if_set()

func _on_continue_game_button_pressed() -> void:
	GameState.continue_game()
	load_game_scene()

func _on_level_select_button_pressed() -> void:
	_open_sub_menu(level_select_scene)

func _on_new_game_confirmation_dialog_confirmed() -> void:
	GameState.reset()
	load_game_scene()
