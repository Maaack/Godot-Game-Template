extends Node


var loading_screen = preload("res://Scenes/LoadingScreen/LoadingScreen.tscn")
var scene_to_load : String

func reload_current_scene() -> void:
	get_tree().reload_current_scene()

func load_scene(path : String) -> void:
	if path == "":
		return
	if scene_to_load != path:
		scene_to_load = path
		ResourceLoader.load_threaded_request(scene_to_load)
	get_tree().paused = false
	var err = get_tree().change_scene_to_packed(loading_screen)
	if err:
		print("failed to load loading screen: %d" % err)
		get_tree().quit()

func get_status():
	if scene_to_load == null or scene_to_load == "":
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get_status(scene_to_load)

func get_progress():
	if scene_to_load == null or scene_to_load == "":
		return
	var progress_array : Array = []
	ResourceLoader.load_threaded_get_status(scene_to_load, progress_array)
	return progress_array.pop_back()

func get_resource():
	if scene_to_load == null or scene_to_load == "":
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get(scene_to_load)
