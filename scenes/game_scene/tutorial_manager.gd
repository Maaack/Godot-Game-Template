extends Node
## A script to add into a level or game scene to display tutorial windows.

## A list of tutorial scenes to open, one after the other.
@export var tutorial_scenes : Array[PackedScene]
## If true, open the tutorials when the scene becomes ready.
@export var auto_open : bool = false
## Delay before opening the tutorials when the scene becomes ready.
@export var auto_open_delay : float = 0.25

func open_tutorials() -> void:
	var _initial_focus_control : Control = get_viewport().gui_get_focus_owner()
	for tutorial_scene in tutorial_scenes:
		var tutorial_menu : Control = tutorial_scene.instantiate()
		if tutorial_menu == null:
			push_warning("tutorial failed to open %s" % tutorial_scene)
			return
		get_tree().current_scene.call_deferred("add_child", tutorial_menu)
		await tutorial_menu.tree_exited
		if is_inside_tree() and _initial_focus_control:
			_initial_focus_control.grab_focus()

func _ready() -> void:
	if auto_open:
		if auto_open_delay > 0.0:
			await get_tree().create_timer(auto_open_delay, false).timeout
		open_tutorials.call_deferred()
