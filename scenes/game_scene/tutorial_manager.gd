extends Node
@export var tutorial_scenes : Array[PackedScene]
@export var open_delay : float = 0.25
@export var auto_open : bool = false

func open_tutorials() -> void:
	if open_delay > 0.0:
		await get_tree().create_timer(open_delay, false).timeout
	for tutorial_scene in tutorial_scenes:
		var tutorial_menu : OverlaidMenu = tutorial_scene.instantiate()
		if tutorial_menu == null:
			push_warning("tutorial failed to open %s" % tutorial_scene)
			return
		get_tree().current_scene.call_deferred("add_child", tutorial_menu)
		await tutorial_menu.tree_exited

func _ready() -> void:
	if auto_open:
		open_tutorials()
