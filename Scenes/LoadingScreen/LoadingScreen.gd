extends CanvasLayer

const LOADING_COMPLETE_TEXT = "Loading Complete!"

func set_new_scene(scene_resource : Resource):
	var scene_instance : Node = scene_resource.instance()
	var _err = scene_instance.connect("ready", self, "queue_free")
	get_node("/root").add_child(scene_instance)
	get_tree().current_scene = scene_instance

func _process(_delta):
	var err = SceneLoader.loader.poll()
	if err == OK:
		$Control/VBoxContainer/ProgressBar.value = SceneLoader.loader.get_stage() * 100 / SceneLoader.loader.get_stage_count()
	elif err == ERR_FILE_EOF:
		$Control/VBoxContainer/ProgressBar.value = 100
		$Control/VBoxContainer/Title.text = LOADING_COMPLETE_TEXT
		set_process(false)
		yield(get_tree().create_timer(0.1), "timeout")
		var resource = SceneLoader.loader.get_resource()
		set_new_scene(resource)
	else:
		$Control/ErrorMsg.dialog_text = "Loading Error: %d" % err
		$Control/ErrorMsg.popup_centered()
		set_process(false)

func _on_ErrorMsg_confirmed():
	var err = get_tree().change_scene(ProjectSettings.get_setting("application/run/main_scene"))
	if err:
		print("failed to load main scene: %d" % err)
		get_tree().quit()
