class_name Credits
extends Control

signal end_reached

func _on_scroll_container_end_reached() -> void:
	end_reached.emit()
