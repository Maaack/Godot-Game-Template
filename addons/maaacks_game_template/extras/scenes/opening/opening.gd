extends Control

@export_file("*.tscn") var next_scene : String
@export var images : Array[Texture2D]
@export var start_delay : float = 0.5
@export var end_delay : float = 0.5
@export var show_loading_screen : bool = false

func next():
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
		texture_rect.visible = false
		%ImagesContainer.call_deferred("add_child", texture_rect)

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel")

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _unhandled_input(event):
	if _event_skips_intro(event):
		next()

func _gui_input(event):
	if _event_is_mouse_button_released(event):
		next()

func _finished_animating():
	await(get_tree().create_timer(end_delay).timeout)
	next()

func _animate_images():
	for texture_rect in %ImagesContainer.get_children():
		texture_rect.show()
		%AnimationPlayer.play("FadeInOut")
		await(%AnimationPlayer.animation_finished)
		texture_rect.hide()
	_finished_animating()

func _ready():
	SceneLoader.load_scene(next_scene, true)
	_add_textures_to_container(images)
	await(get_tree().create_timer(start_delay).timeout)
	_animate_images()
