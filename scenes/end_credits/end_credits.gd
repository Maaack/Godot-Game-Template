@tool
extends Credits

@export_file("*.tscn") var main_menu_scene : String
@onready var init_mouse_filter : MouseFilter = mouse_filter

func _end_reached() -> void:
	%EndMessagePanel.show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	super._end_reached()

func _on_MenuButton_pressed() -> void:
	SceneLoader.load_scene(main_menu_scene)

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _ready() -> void:
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()
	super._ready()

func reset() -> void:
	super.reset()
	%EndMessagePanel.hide()
	mouse_filter = init_mouse_filter

func _unhandled_input(event : InputEvent) -> void:
	if not enabled: return
	if event.is_action_pressed("ui_cancel"):
		if not %EndMessagePanel.visible:
			_end_reached()
		else:
			get_tree().quit()
