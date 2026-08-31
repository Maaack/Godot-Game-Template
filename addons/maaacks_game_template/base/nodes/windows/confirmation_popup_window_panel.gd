@tool
class_name ConfirmationPopupWindowPanel
extends PopupWindowPanel

signal confirmed

## Text to use for the confirm button.
@export var confirm_button_text : String = "Confirm" :
	set(value):
		confirm_button_text = value
		if update_content and is_inside_tree():
			confirm_button.text = confirm_button_text

@onready var confirm_button : Button = %ConfirmButton

func _ready() -> void:
	super._ready()
	if not confirm_button.pressed.is_connected(_on_confirm_button_pressed):
		confirm_button.pressed.connect(_on_confirm_button_pressed)

func confirm():
	confirmed.emit()
	close()

func _on_confirm_button_pressed():
	confirm()
