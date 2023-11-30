extends Control

@export_file("*.tscn") var next_scene : String
@export var images : Array[Texture2D]
@export var start_delay : float = 0.5
@export var end_delay : float = 0.5

func next():
	var status = SceneLoader.get_status()
	if SceneLoader.get_status() == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene = SceneLoader.get_resource()
		get_tree().change_scene_to_packed(packed_scene)
	else:
		SceneLoader.show_loading_screen()

func _add_textures_to_container(textures : Array[Texture2D]):
	for texture in textures:
		var texture_rect : TextureRect = TextureRect.new()
		texture_rect.texture = texture
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.visible = false
		%ImagesContainer.call_deferred("add_child", texture_rect)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		next()

func _gui_input(event):
	if event is InputEventMouseButton:
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
