extends Node
@export var tutorial_scenes : Array[PackedScene]
@export var delay : float = 0.25

func open_tutorials() -> void:
	for tutorial_scene in tutorial_scenes:
		var tutorial_menu : OverlaidMenu = tutorial_scene.instantiate()
		if tutorial_menu == null:
			push_warning("tutorial failed to open %s" % tutorial_scene)
			return
		get_tree().current_scene.call_deferred("add_child", tutorial_menu)
		await tutorial_menu.tree_exited

func _ready() -> void:
	await get_tree().create_timer(delay, false).timeout
	open_tutorials()
