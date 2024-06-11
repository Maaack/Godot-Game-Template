@tool
extends Credits

@export_file("*.tscn") var main_menu_scene : String

func _end_reached():
	%EndMessagePanel.show()
	super._end_reached()

func _on_MenuButton_pressed():
	SceneLoader.load_scene(main_menu_scene)

func _on_ExitButton_pressed():
	get_tree().quit()

func _ready():
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()
	super._ready()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not %EndMessagePanel.visible:
			_end_reached()
		else:
			get_tree().quit()
