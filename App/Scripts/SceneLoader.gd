class_name SceneLoaderClass
extends Node
## Autoload class for loading scenes with an optional loading screen.

signal scene_loaded

var _loading_screen : PackedScene
var _scene_path : String
var _loaded_resource : Resource
var _background_loading : bool

func set_loading_screen(loading_screen_path : String):
	if loading_screen_path == "":
		push_warning("loading screen path is empty")
		return
	_loading_screen = load(loading_screen_path)

func reload_current_scene() -> void:
	get_tree().reload_current_scene()

func has_loading_screen():
	return _loading_screen != null

func _check_loading_screen():
	if not has_loading_screen():
		push_error("loading screen is not set")
		return false
	return true

func _load_loading_screen():
	var err = get_tree().change_scene_to_packed(_loading_screen)
	if err:
		push_error("failed to load loading screen: %d" % err)
		get_tree().quit()

func load_scene(scene_path : String, in_background : bool = false) -> void:
	if scene_path == null or scene_path.is_empty():
		push_error("no path given to load")
		return
	if ResourceLoader.has_cached(scene_path):
		call_deferred("emit_signal", "scene_loaded")
		return
	_scene_path = scene_path
	_background_loading = in_background
	ResourceLoader.load_threaded_request(_scene_path)
	if _background_loading or not _check_loading_screen():
		set_process(true)
	else:
		_load_loading_screen()

func get_status():
	if _scene_path == null or _scene_path == "":
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get_status(_scene_path)

func get_progress():
	if _scene_path == null or _scene_path == "":
		return
	var progress_array : Array = []
	ResourceLoader.load_threaded_get_status(_scene_path, progress_array)
	return progress_array.pop_back()

func get_resource():
	if _scene_path == null or _scene_path == "":
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	var current_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
	if current_loaded_resource != null:
		_loaded_resource = current_loaded_resource
	return _loaded_resource

func _switch_scene_to_resource():
	var err = get_tree().change_scene_to_packed(get_resource())
	if err:
		push_error("failed to switch scenes: %d" % err)
		get_tree().quit()

func _process(_delta):
	var status = get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			emit_signal("scene_loaded")
			set_process(false)
			if not _background_loading:
				_switch_scene_to_resource()
				
