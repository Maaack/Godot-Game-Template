extends ScrollContainer

signal end_reached

@onready var header_space : Control = %HeaderSpace
@onready var footer_space : Control = %FooterSpace
@onready var credits_label : Control = %CreditsLabel
var timer : Timer = Timer.new()

@export var auto_scroll_speed: float = 60.0
@export var input_scroll_speed : float = 400.0
@export var scroll_restart_delay : float = 1.5

var _current_scroll_position : float = 0.0
var scroll_paused : bool = false

func _end_reached() -> void:
	scroll_paused = true
	emit_signal("end_reached")

func is_end_reached() -> bool:
	var _end_of_credits_vertical = credits_label.size.y + header_space.size.y
	return scroll_vertical > _end_of_credits_vertical

func _check_end_reached() -> void:
	if not is_end_reached():
		return
	_end_reached()

func _scroll_container(amount : float) -> void:
	if not visible or scroll_paused:
		return
	_current_scroll_position += amount
	scroll_vertical = round(_current_scroll_position)
	_check_end_reached()

func _on_gui_input(event : InputEvent) -> void:
	# Captures the mouse scroll wheel input event
	if event is InputEventMouseButton:
		scroll_paused = true
		_start_scroll_restart_timer()
	_check_end_reached()

func _on_scroll_started() -> void:
	# Captures the touch input event
	scroll_paused = true
	_start_scroll_restart_timer()

func _start_scroll_restart_timer() -> void:
	timer.start(scroll_restart_delay)

func _on_scroll_restart_timer_timeout() -> void:
	_current_scroll_position = scroll_vertical
	scroll_paused = false

func _on_resized() -> void:
	_current_scroll_position = scroll_vertical

func _on_visibility_changed() -> void:
	if visible:
		scroll_vertical = 0
		_current_scroll_position = scroll_vertical
		scroll_paused = false

func _ready() -> void:
	scroll_started.connect(_on_scroll_started)
	gui_input.connect(_on_gui_input)
	resized.connect(_on_resized)
	visibility_changed.connect(_on_visibility_changed)
	timer.timeout.connect(_on_scroll_restart_timer_timeout)
	add_child(timer)

func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
	var input_axis = Input.get_axis("ui_up", "ui_down")
	if input_axis != 0:
		_scroll_container(input_axis * input_scroll_speed * delta)
	else:
		_scroll_container(auto_scroll_speed * delta)
