class_name ScrollingCredits
extends Credits

signal end_reached

@onready var header_space : Control = %HeaderSpace
@onready var footer_space : Control = %FooterSpace
@onready var credits_label : Control = %CreditsLabel

func set_header_and_footer() -> void:
	header_space.custom_minimum_size.y = size.y
	footer_space.custom_minimum_size.y = size.y
	credits_label.custom_minimum_size.x = size.x

func _on_scroll_container_end_reached() -> void:
	end_reached.emit()

func _on_resized() -> void:
	set_header_and_footer()

func _ready() -> void:
	resized.connect(_on_resized)
	set_header_and_footer()
