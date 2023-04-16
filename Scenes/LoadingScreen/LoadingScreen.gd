extends CanvasLayer

const LOADING_COMPLETE_TEXT = "Loading Complete!"

func set_new_scene(scene_resource : Resource):
	var scene_instance : Node = scene_resource.instantiate()
	var _err = scene_instance.connect("ready", Callable(self, "queue_free"))
	get_node("/root").add_child(scene_instance)
	get_tree().current_scene = scene_instance

func _process(_delta):
	var status = SceneLoader.get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$Control/VBoxContainer/ProgressBar.value = SceneLoader.get_progress()
		ResourceLoader.THREAD_LOAD_LOADED:
			$Control/VBoxContainer/ProgressBar.value = 100
			$Control/VBoxContainer/Title.text = LOADING_COMPLETE_TEXT
			set_process(false)
			await get_tree().create_timer(0.1).timeout
			var resource = SceneLoader.get_resource()
			set_new_scene(resource)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			$Control/ErrorMsg.dialog_text = "Loading Error: %d" % status
			$Control/ErrorMsg.popup_centered()
			set_process(false)

func _on_ErrorMsg_confirmed():
	var err = get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	if err:
		print("failed to load main scene: %d" % err)
		get_tree().quit()
