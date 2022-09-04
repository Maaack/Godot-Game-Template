extends Node


var loading_screen = preload("res://Scenes/LoadingScreen/LoadingScreen.tscn")
var loader : ResourceInteractiveLoader
var scene_to_load : String

func reload_current_scene() -> void:
	load_scene(scene_to_load)

func load_scene(path : String) -> void:
	if path == "":
		return
	if scene_to_load != path or loader == null:
		scene_to_load = path
		loader = ResourceLoader.load_interactive(scene_to_load)
	get_tree().paused = false
	var err = get_tree().change_scene_to(loading_screen)
	if err:
		print("failed to load loading screen: %d" % err)
		get_tree().quit()
