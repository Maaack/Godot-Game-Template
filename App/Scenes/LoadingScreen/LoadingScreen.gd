extends CanvasLayer

const LOADING_COMPLETE_TEXT = "Loading Complete!"

var loading_timeout : bool = false
var loading_progress : float = 0.0 :
	set(value):
		if value == loading_progress:
			return
		loading_progress = value
		loading_timeout = false
		%LoadingTimer.start()
		%ProgressBar.value = loading_progress

func set_new_scene(scene_resource : Resource):
	var scene_instance : Node = scene_resource.instantiate()
	var _err = scene_instance.connect("ready", Callable(self, "queue_free"))
	get_node("/root").add_child(scene_instance)
	get_tree().current_scene = scene_instance

func _process(_delta):
	var status = SceneLoader.get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress = SceneLoader.get_progress()
			if loading_timeout:
				if %ErrorMessage.visible:
					return
				if loading_progress == 0:
					%ErrorMessage.dialog_text = "Loading Error: Taking too long to start."
				else:
					%ErrorMessage.dialog_text = "Loading Error: Stalled at %d%%." % (loading_progress * 100.0)
				%ErrorMessage.popup_centered()
			else:
				%ErrorMessage.hide()
		ResourceLoader.THREAD_LOAD_LOADED:
			loading_progress = 1.0
			%Title.text = LOADING_COMPLETE_TEXT
			set_process(false)
			await get_tree().create_timer(0.1).timeout
			var resource = SceneLoader.get_resource()
			set_new_scene(resource)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			%ErrorMessage.dialog_text = "Loading Error: %d" % status
			%ErrorMessage.popup_centered()
			set_process(false)

func _on_loading_timer_timeout():
	loading_timeout = true

func _on_error_message_confirmed():
	var err = get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	if err:
		print("failed to load main scene: %d" % err)
		get_tree().quit()
