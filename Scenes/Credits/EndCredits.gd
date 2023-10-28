extends "res://Scenes/Credits/Credits.gd"

func end_reached():
	var node = get_node_or_null("%EndMessagePanel")
	if node == null:
		return
	node.show()

func _on_MenuButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()

func _ready():
	if OS.has_feature("web"):
		var node = get_node_or_null("%ExitButton")
		if node == null:
			return
		node.hide()
