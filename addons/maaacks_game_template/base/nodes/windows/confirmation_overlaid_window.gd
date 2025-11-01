@tool
class_name ConfirmationOverlaidWindow
extends OverlaidWindow

signal confirmed

@onready var confirm_button : Button = %ConfirmButton

@export var confirm_button_text : String = "Confirm" :
	set(value):
		confirm_button_text = value
		if update_content and is_inside_tree():
			confirm_button.text = confirm_button_text

func confirm():
	confirmed.emit()
	close()

func _on_confirm_button_pressed():
	confirm()
