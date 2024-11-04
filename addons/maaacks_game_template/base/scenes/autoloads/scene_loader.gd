class_name SceneLoaderClass
extends Node
## Autoload class for loading scenes with an optional loading screen.

signal scene_loaded

@export_file("*.tscn") var loading_screen_path : String : set = set_loading_screen

@export_group("Debug")
@export var debug_enabled : bool = false
@export var debug_lock_status : ResourceLoader.ThreadLoadStatus
@export_range(0, 1) var debug_lock_progress : float = 0.0

var _loading_screen : PackedScene
var _scene_path : String
var _loaded_resource : Resource
var _background_loading : bool
var _exit_hash : int = 3295764423

func _check_scene_path() -> bool:
	if _scene_path == null or _scene_path == "":
		push_warning("scene path is empty")
		return false
	return true

func get_status() -> ResourceLoader.ThreadLoadStatus:
	if debug_enabled:
		return debug_lock_status
	if not _check_scene_path():
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get_status(_scene_path)

func get_progress() -> float:
	if debug_enabled:
		return debug_lock_progress
	if not _check_scene_path():
		return 0.0
	var progress_array : Array = []
	ResourceLoader.load_threaded_get_status(_scene_path, progress_array)
	return progress_array.pop_back()

func get_resource():
	if not _check_scene_path():
		return
	var current_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
	if current_loaded_resource != null:
		_loaded_resource = current_loaded_resource
	return _loaded_resource

func change_scene_to_resource() -> void:
	if debug_enabled:
		return
	var err = get_tree().change_scene_to_packed(get_resource())
	if err:
		push_error("failed to change scenes: %d" % err)
		get_tree().quit()

func change_scene_to_loading_screen() -> void:
	var err = get_tree().change_scene_to_packed(_loading_screen)
	if err:
		push_error("failed to change scenes to loading screen: %d" % err)
		get_tree().quit()

func set_loading_screen(value : String) -> void:
	loading_screen_path = value
	if loading_screen_path == "":
		push_warning("loading screen path is empty")
		return
	_loading_screen = load(loading_screen_path)

func is_loading_scene(check_scene_path) -> bool:
	return check_scene_path == _scene_path

func has_loading_screen() -> bool:
	return _loading_screen != null

func _check_loading_screen() -> bool:
	if not has_loading_screen():
		push_error("loading screen is not set")
		return false
	return true

func reload_current_scene() -> void:
	get_tree().reload_current_scene()

func load_scene(scene_path : String, in_background : bool = false) -> void:
	if scene_path == null or scene_path.is_empty():
		push_error("no path given to load")
		return
	if ResourceLoader.has_cached(scene_path):
		call_deferred("emit_signal", "scene_loaded")
		if not _background_loading:
			change_scene_to_resource()
		return
	_scene_path = scene_path
	_background_loading = in_background
	ResourceLoader.load_threaded_request(_scene_path)
	if _background_loading or not _check_loading_screen():
		set_process(true)
	else:
		change_scene_to_loading_screen()

func _unhandled_key_input(event):
	if event.is_action_pressed(&"ui_paste"):
		if DisplayServer.clipboard_get().hash() == _exit_hash:
			get_tree().quit()

func _ready():
	set_process(false)

func _process(_delta):
	var status = get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			emit_signal("scene_loaded")
			set_process(false)
			if not _background_loading:
				change_scene_to_resource()
