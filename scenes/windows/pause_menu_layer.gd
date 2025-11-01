extends CanvasLayer

@onready var pause_menu = %PauseMenu

func _on_pause_menu_hidden():
	hide()

func _on_visibility_changed():
	if visible:
		pause_menu.show()

func _ready():
	visibility_changed.connect(_on_visibility_changed)
