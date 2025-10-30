extends Node

## Node for opening a pause menu when detecting a 'ui_cancel' event.

@export var pause_menu_packed : PackedScene
@export var focused_viewport : Viewport

var pause_menu : Node

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible: return
		if not focused_viewport:
			focused_viewport = get_viewport()
		var _initial_focus_control = focused_viewport.gui_get_focus_owner()
		pause_menu.show()
		if pause_menu is CanvasLayer:
			await pause_menu.visibility_changed
		else:
			await pause_menu.hidden
		if is_inside_tree() and _initial_focus_control:
			_initial_focus_control.grab_focus()

func _ready() -> void:
	pause_menu = pause_menu_packed.instantiate()
	pause_menu.hide()
	get_tree().current_scene.call_deferred("add_child", pause_menu)
