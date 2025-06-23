@tool
class_name ScrollableCredits
extends Credits

@onready var credits_label : RichTextLabel = %CreditsLabel

@export var input_scroll_speed : float = 400.0

func _on_visibility_changed() -> void:
	if visible:
		credits_label.scroll_to_line(0)
		credits_label.grab_focus()

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _process(delta : float) -> void:
	if Engine.is_editor_hint() or not visible:
		return
	var input_axis = Input.get_axis("ui_up", "ui_down")
	if input_axis != 0:
		credits_label.get_v_scroll_bar().value += input_axis * delta * input_scroll_speed
