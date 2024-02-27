extends CanvasLayer

const LOADING_COMPLETE_TEXT = "Loading Complete!"
const LOADING_COMPLETE_TEXT_WAITING = "Any Moment Now..."
const LOADING_TEXT = "Loading..."
const LOADING_TEXT_WAITING = "Still Loading..."

const QUADMESH_PLACEHOLDER = preload("res://App/Scenes/LoadingScreen/QuadMeshPlaceholder.tscn")

enum StallStage{STARTED, WAITING, GIVE_UP}

@export_dir var _spatial_shader_material_dir : String = "res://Assets/Materials/"
@export var _cache_spatial_shader : bool = false

var _stall_stage : StallStage = StallStage.STARTED
var _loading_complete : bool = false
var _loading_progress : float = 0.0 :
	set(value):
		if value <= _loading_progress:
			return
		_loading_progress = value
		%ProgressBar.value = _loading_progress/2 + _caching_progress/2 \
			if _cache_spatial_shader and SceneLoader.is_loading_main_game_scene() \
			else _loading_progress
		_reset_loading_stage()
		
var _caching_progress : float = 0.0 :
	set(value):
		if value <= _caching_progress:
			return
		_caching_progress = value
		%ProgressBar.value = _loading_progress/2 + _caching_progress/2 \
			if _cache_spatial_shader and SceneLoader.is_loading_main_game_scene() \
			else _loading_progress
		
var _changing_to_next_scene : bool = false

func _reset_loading_stage():
	_stall_stage = StallStage.STARTED
	%LoadingTimer.start()

func _load_next_scene():
	if _changing_to_next_scene:
		return
	_changing_to_next_scene = true
	if _cache_spatial_shader and SceneLoader.is_loading_main_game_scene():
		_show_all_draw_passes_once()
	else:
		SceneLoader.change_scene_to_resource()

func _show_all_draw_passes_once():
	var all_materials = _traverse_folders(_spatial_shader_material_dir)
	var total_material_count = all_materials.size()
	var cached_material_count = 0
	for material_path in all_materials:
		_load_material(material_path)
		cached_material_count += 1
		_caching_progress = float(cached_material_count) / total_material_count
	_load_world_scene()
		
func _traverse_folders(dir_path:String) -> PackedStringArray:
	var material_list:PackedStringArray = []
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("An error occurred when trying to access the path ", dir_path)
		return []
	
	if dir.list_dir_begin() != OK:
		push_error("An error occurred when trying to access the path ", dir_path)
		return []
	
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if not file_name.ends_with(".import") and not file_name.ends_with(".png"):
				material_list.append(dir_path + file_name)
		else:
			var subfolder_name = file_name
			if subfolder_name != "." and subfolder_name != ".." and subfolder_name != "Noise":
				material_list.append_array(_traverse_folders(dir_path + subfolder_name + "/"))
		file_name = dir.get_next()
	
	return material_list
	
func _load_material(path:String):
	var material_shower = QUADMESH_PLACEHOLDER.instantiate()
	var material := ResourceLoader.load(path) as Material
	material_shower.set_surface_override_material(0, material)
	%SpatialShaderTypeCaches.add_child(material_shower)

func _load_world_scene():
	SceneLoader.change_scene_to_resource()

func _process(_delta):
	if _loading_complete:
		call_deferred("_load_next_scene")
	var status = SceneLoader.get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_loading_progress = SceneLoader.get_progress()
			match _stall_stage:
				StallStage.STARTED:
					%ErrorMessage.hide()
					%Title.text = LOADING_TEXT
				StallStage.WAITING:
					%ErrorMessage.hide()
					%Title.text = LOADING_TEXT_WAITING
				StallStage.GIVE_UP:
					if %ErrorMessage.visible:
						return
					if _loading_progress == 0:
						%ErrorMessage.dialog_text = "Loading Error: Failed to start."
						if OS.has_feature("web"):
							%ErrorMessage.dialog_text += "\nTry refreshing the page."
					else:
						%ErrorMessage.dialog_text = "Loading Error: Failed at %d%%." % (_loading_progress * 100.0)
					%ErrorMessage.popup_centered()
		ResourceLoader.THREAD_LOAD_LOADED:
			_loading_progress = 1.0
			_loading_complete = true
			match _stall_stage:
				StallStage.STARTED:
					%ErrorMessage.hide()
					%Title.text = LOADING_COMPLETE_TEXT
				StallStage.WAITING:
					%ErrorMessage.hide()
					%Title.text = LOADING_COMPLETE_TEXT_WAITING
				StallStage.GIVE_UP:
					if %ErrorMessage.visible:
						return
					%ErrorMessage.dialog_text = "Loading Error: Failed to switch scenes."
					%ErrorMessage.popup_centered()
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			%ErrorMessage.dialog_text = "Loading Error: %d" % status
			%ErrorMessage.popup_centered()
			set_process(false)

func _on_loading_timer_timeout():
	var prev_stage : StallStage = _stall_stage
	match prev_stage:
		StallStage.STARTED:
			_stall_stage = StallStage.WAITING
			%LoadingTimer.start()
		StallStage.WAITING:
			_stall_stage = StallStage.GIVE_UP

func _on_error_message_confirmed():
	var err = get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	if err:
		print("failed to load main scene: %d" % err)
		get_tree().quit()
