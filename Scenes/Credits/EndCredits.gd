@tool
extends "res://Scenes/Credits/Credits.gd"

@export_file("*.tscn") var main_menu_scene : String

func _end_reached():
	var node = get_node_or_null("%EndMessagePanel")
	if node == null:
		return
	node.show()
	super._end_reached()

func _on_MenuButton_pressed():
	SceneLoader.load_scene(main_menu_scene)

func _on_ExitButton_pressed():
	get_tree().quit()

func _ready():
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()
	super._ready()
