extends CanvasLayer

const LOADING_COMPLETE_TEXT = "Loading Complete!"
const LOADING_COMPLETE_TEXT_WAITING = "Any Moment Now..."
const LOADING_TEXT = "Loading..."
const LOADING_TEXT_WAITING = "Still Loading..."

enum StallStage{STARTED, WAITING, GIVE_UP}
var stall_stage : StallStage = StallStage.STARTED
var loading_complete : bool = false

var loading_progress : float = 0.0 :
	set(value):
		if value == loading_progress:
			return
		loading_progress = value
		%ProgressBar.value = loading_progress
		_reset_loading_stage()

func _reset_loading_stage():
	stall_stage = StallStage.STARTED
	%LoadingTimer.start()

func set_new_scene(scene_resource : Resource):
	var scene_instance : Node = scene_resource.instantiate()
	var _err = scene_instance.connect("ready", Callable(self, "queue_free"))
	get_node("/root").add_child(scene_instance)
	get_tree().current_scene = scene_instance

func _set_loading_complete():
	if loading_complete:
		return
	loading_complete = true
	await get_tree().create_timer(0.1).timeout
	var resource = SceneLoader.get_resource()
	set_new_scene(resource)

func _process(_delta):
	var status = SceneLoader.get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress = SceneLoader.get_progress()
			match stall_stage:
				StallStage.STARTED:
					%ErrorMessage.hide()
					%Title.text = LOADING_TEXT
				StallStage.WAITING:
					%ErrorMessage.hide()
					%Title.text = LOADING_TEXT_WAITING
				StallStage.GIVE_UP:
					if %ErrorMessage.visible:
						return
					if loading_progress == 0:
						%ErrorMessage.dialog_text = "Loading Error: Failed to start."
					else:
						%ErrorMessage.dialog_text = "Loading Error: Failed at %d%%." % (loading_progress * 100.0)
					%ErrorMessage.popup_centered()
		ResourceLoader.THREAD_LOAD_LOADED:
			loading_progress = 1.0
			match stall_stage:
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
			_set_loading_complete()
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			%ErrorMessage.dialog_text = "Loading Error: %d" % status
			%ErrorMessage.popup_centered()
			set_process(false)

func _on_loading_timer_timeout():
	stall_stage += 1
	if stall_stage >= StallStage.size():
		stall_stage = StallStage.GIVE_UP
	else:
		%LoadingTimer.start()

func _on_error_message_confirmed():
	var err = get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	if err:
		print("failed to load main scene: %d" % err)
		get_tree().quit()
