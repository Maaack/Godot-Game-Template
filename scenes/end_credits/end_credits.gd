extends ScrollingCredits

@export_file("*.tscn") var main_menu_scene : String
## This option forces the mouse to be visible when the menu shows up.
## Useful for games that capture the mouse, and don't automatically return it.
@export var force_mouse_mode_visible : bool = false

@onready var end_message_panel = %EndMessagePanel
@onready var exit_button = %ExitButton
@onready var menu_button = %MenuButton
@onready var init_mouse_filter : MouseFilter = mouse_filter

func _on_scroll_container_end_reached() -> void:
	end_message_panel.show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	if force_mouse_mode_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	super._on_scroll_container_end_reached()

func load_main_menu() -> void:
	SceneLoader.load_scene(main_menu_scene)

func exit_game() -> void:
	if OS.has_feature("web"):
		load_main_menu()
	get_tree().quit()

func _on_visibility_changed() -> void:
	if visible:
		end_message_panel.hide()
		mouse_filter = init_mouse_filter

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if main_menu_scene.is_empty():
		menu_button.hide()
	if OS.has_feature("web"):
		exit_button.hide()
	super._ready()

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if not end_message_panel.visible:
			_on_scroll_container_end_reached()
		else:
			exit_game()

func _on_exit_button_pressed():
	exit_game()

func _on_menu_button_pressed():
	load_main_menu()
