extends Node

const TOTAL_RUN_TIME = "TotalRunTime"
const UPDATE_COUNTER_RESET = 3.0

var total_run_time : float = 0.0
var update_counter : float = 0.0

func _process(delta):
	total_run_time += delta
	update_counter += delta
	if update_counter > UPDATE_COUNTER_RESET:
		update_counter = 0.0
		Config.set_config(AppLog.APP_LOG_SECTION, TOTAL_RUN_TIME, total_run_time)

func _set_local_from_config() -> void:
	total_run_time = Config.get_config(AppLog.APP_LOG_SECTION, TOTAL_RUN_TIME, total_run_time)

func _init():
	_set_local_from_config()
