class_name LoadingScreen
extends CanvasLayer

const LOADING_COMPLETE_TEXT = "Loading Complete!"
const LOADING_COMPLETE_TEXT_WAITING = "Any Moment Now..."
const LOADING_COMPLETE_TEXT_STILL_WAITING = "Any Moment Now... (%d seconds)"
const LOADING_TEXT = "Loading..."
const LOADING_TEXT_WAITING = "Still Loading..."
const LOADING_TEXT_STILL_WAITING = "Still Loading... (%d seconds)"

enum StallStage{STARTED, WAITING, STILL_WAITING, GIVE_UP}
var _stall_stage : StallStage = StallStage.STARTED
var _scene_loading_complete : bool = false
var _scene_loading_progress : float = 0.0 :
	set(value):
		_scene_loading_progress = value
		update_total_loading_progress()
		_reset_loading_stage()

var _changing_to_next_scene : bool = false
var _total_loading_progress : float = 0.0 :
	set(value):
		_total_loading_progress = value
		%ProgressBar.value = _total_loading_progress
var _loading_start_time : int

func update_total_loading_progress():
	_total_loading_progress = _scene_loading_progress

func _reset_loading_stage():
	_stall_stage = StallStage.STARTED
	%LoadingTimer.start()

func _reset_loading_start_time():
	_loading_start_time = Time.get_ticks_msec()

func _try_loading_next_scene():
	if not _scene_loading_complete:
		return
	_load_next_scene()

func _load_next_scene():
	if _changing_to_next_scene:
		return
	_changing_to_next_scene = true
	SceneLoader.call_deferred("change_scene_to_resource")

func _get_seconds_waiting() -> int:
	return int((Time.get_ticks_msec() - _loading_start_time) / 1000.0)

func _update_scene_loading_progress():
	var new_progress = SceneLoader.get_progress()
	if new_progress > _scene_loading_progress:
		_scene_loading_progress = new_progress

func _set_scene_loading_complete():
	_scene_loading_progress = 1.0
	_scene_loading_complete = true

func _reset_scene_loading_progress():
	_scene_loading_progress = 0.0
	_scene_loading_complete = false

func _show_loading_stalled_error_message():
	if %ErrorMessage.visible:
		return
	if _scene_loading_progress == 0:
		%ErrorMessage.dialog_text = "Loading Error: Stalled at start."
		if OS.has_feature("web"):
			%ErrorMessage.dialog_text += "\nTry refreshing the page."
	else:
		%ErrorMessage.dialog_text = "Loading Error: Stalled at %d%%." % (_scene_loading_progress * 100.0)
	%ErrorMessage.popup_centered()

func _show_scene_switching_error_message():
	if %ErrorMessage.visible:
		return
	%ErrorMessage.dialog_text = "Loading Error: Failed to switch scenes."
	%ErrorMessage.popup_centered()

func _update_in_progress_messaging():
	match _stall_stage:
		StallStage.STARTED:
			%ErrorMessage.hide()
			%Title.text = LOADING_TEXT
		StallStage.WAITING:
			%ErrorMessage.hide()
			%Title.text = LOADING_TEXT_WAITING
		StallStage.STILL_WAITING:
			%ErrorMessage.hide()
			%Title.text = LOADING_TEXT_STILL_WAITING % _get_seconds_waiting()
		StallStage.GIVE_UP:
			_show_loading_stalled_error_message()
			%Title.text = LOADING_TEXT_STILL_WAITING % _get_seconds_waiting()

func _update_loaded_messaging():
	match _stall_stage:
		StallStage.STARTED:
			%ErrorMessage.hide()
			%Title.text = LOADING_COMPLETE_TEXT
		StallStage.WAITING:
			%ErrorMessage.hide()
			%Title.text = LOADING_COMPLETE_TEXT_WAITING
		StallStage.STILL_WAITING:
			%ErrorMessage.hide()
			%Title.text = LOADING_COMPLETE_TEXT_STILL_WAITING % _get_seconds_waiting()
		StallStage.GIVE_UP:
			_show_scene_switching_error_message()
			%Title.text = LOADING_COMPLETE_TEXT_STILL_WAITING % _get_seconds_waiting()

func _process(_delta):
	_try_loading_next_scene()
	var status = SceneLoader.get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_update_scene_loading_progress()
			_update_in_progress_messaging()
		ResourceLoader.THREAD_LOAD_LOADED:
			_set_scene_loading_complete()
			_update_loaded_messaging()
		ResourceLoader.THREAD_LOAD_FAILED:
			%ErrorMessage.dialog_text = "Loading Error: %d" % status
			%ErrorMessage.popup_centered()
			set_process(false)
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			%ErrorMessage.hide()
			set_process(false)

func _on_loading_timer_timeout():
	var prev_stage : StallStage = _stall_stage
	match prev_stage:
		StallStage.STARTED:
			_stall_stage = StallStage.WAITING
			%LoadingTimer.start()
		StallStage.WAITING:
			_stall_stage = StallStage.STILL_WAITING
			%LoadingTimer.start()
		StallStage.STILL_WAITING:
			_stall_stage = StallStage.GIVE_UP

func _on_error_message_confirmed():
	var err = get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	if err:
		push_error("failed to load main scene: %d" % err)
		get_tree().quit()

func reset():
	show()
	_reset_loading_stage()
	_reset_scene_loading_progress()
	_reset_loading_start_time()
	%ErrorMessage.hide()
	set_process(true)

func close():
	set_process(false)
	%ErrorMessage.hide()
	hide()
