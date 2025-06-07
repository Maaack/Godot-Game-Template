@tool
class_name ScrollableCredits
extends Credits

@onready var credits_label : RichTextLabel = %CreditsLabel

func _on_visibility_changed() -> void:
	if visible:
		credits_label.scroll_to_line(0)

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
