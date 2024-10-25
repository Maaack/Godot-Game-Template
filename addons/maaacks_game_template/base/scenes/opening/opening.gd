extends Control

@export_file("*.tscn") var next_scene : String
@export var images : Array[Texture2D]
@export_group("Animation")
@export var fade_in_time : float = 0.2
@export var fade_out_time : float = 0.2
@export var visible_time : float = 1.6
@export_group("Transition")
@export var start_delay : float = 0.5
@export var end_delay : float = 0.5
@export var show_loading_screen : bool = false

var tween : Tween
var next_image_index : int = 0

func _load_next_scene():
	var status = SceneLoader.get_status()
	if show_loading_screen or status != ResourceLoader.THREAD_LOAD_LOADED:
		SceneLoader.change_scene_to_loading_screen()
	else:
		SceneLoader.change_scene_to_resource()

func _add_textures_to_container(textures : Array[Texture2D]):
	for texture in textures:
		var texture_rect : TextureRect = TextureRect.new()
		texture_rect.texture = texture
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.modulate.a = 0.0
		%ImagesContainer.call_deferred("add_child", texture_rect)

func _event_skips_image(event : InputEvent):
	return event.is_action_released(&"ui_accept") or event.is_action_released(&"ui_select")

func _event_skips_intro(event : InputEvent):
	return event.is_action_released(&"ui_cancel")

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _unhandled_input(event):
	if _event_skips_intro(event):
		_load_next_scene()
	elif _event_skips_image(event):
		_show_next_image(false)

func _gui_input(event):
	if _event_is_mouse_button_released(event):
		_show_next_image(false)

func _transition_out():
	await get_tree().create_timer(end_delay).timeout
	_load_next_scene()

func _transition_in():
	await get_tree().create_timer(start_delay).timeout
	if next_image_index == 0:
		_show_next_image()

func _wait_and_fade_out(texture_rect : TextureRect):
	var _compare_next_index = next_image_index
	await get_tree().create_timer(visible_time, false).timeout
	if _compare_next_index != next_image_index : return
	tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 0.0, fade_out_time)
	await tween.finished
	_show_next_image.call_deferred()

func _hide_previous_image():
	if tween and tween.is_running():
		tween.stop()
	if %ImagesContainer.get_child_count() == 0:
		return
	var current_image = %ImagesContainer.get_child(next_image_index - 1)
	if current_image:
		current_image.modulate.a = 0.0

func _show_next_image(animated : bool = true):
	_hide_previous_image()
	if next_image_index >= %ImagesContainer.get_child_count():
		if animated:
			_transition_out()
		else:
			_load_next_scene()
		return
	var texture_rect = %ImagesContainer.get_child(next_image_index)
	if animated: 
		tween = create_tween()
		tween.tween_property(texture_rect, "modulate:a", 1.0, fade_in_time)
		await tween.finished
	else:
		texture_rect.modulate.a = 1.0
	next_image_index += 1
	_wait_and_fade_out(texture_rect)

func _ready():
	SceneLoader.load_scene(next_scene, true)
	_add_textures_to_container(images)
	_transition_in()
