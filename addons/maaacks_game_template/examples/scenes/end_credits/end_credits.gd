extends ScrollingCredits

@export_file("*.tscn") var main_menu_scene : String
## This option forces the mouse to be visible when the menu shows up.
## Useful for games that capture the mouse, and don't automatically return it.
@export var force_mouse_mode_visible : bool = false
@onready var init_mouse_filter : MouseFilter = mouse_filter

func _on_scroll_container_end_reached() -> void:
	%EndMessagePanel.show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	if force_mouse_mode_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	super._on_scroll_container_end_reached()

func _on_MenuButton_pressed() -> void:
	SceneLoader.load_scene(main_menu_scene)

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
	if visible:
		%EndMessagePanel.hide()
		mouse_filter = init_mouse_filter

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()
	super._ready()

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not %EndMessagePanel.visible:
			_on_scroll_container_end_reached()
		else:
			get_tree().quit()
