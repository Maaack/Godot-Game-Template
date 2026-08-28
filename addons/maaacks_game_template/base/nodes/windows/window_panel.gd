@tool
class_name WindowPanel
extends PanelContainer

signal closed

## If true, the `ui_cancel` action (ex. Escape key) will close the window.
@export var ui_cancel_closes : bool = true

@export_group("Content")
## If true, content of the window will be updated to match values in the Inspector.
@export var update_content : bool = false

## Optional title to add to the top of the window.
@export var title : String = "Menu" :
	set(value):
		title = value
		if update_content and is_inside_tree():
			title_label.text = title
			title_margin.visible = not title.is_empty()

## Optional text to add to the body of the window.
@export_multiline var text : String :
	set(value):
		text = value
		if update_content and is_inside_tree():
			description_label.text = text

## Text to use for the close button.
@export var close_button_text : String = "Close" :
	set(value):
		close_button_text = value
		if update_content and is_inside_tree():
			close_button.text = close_button_text

@onready var content_container : Container = %ContentContainer
@onready var title_label : Label = %TitleLabel
@onready var title_margin : MarginContainer = %TitleMargin
@onready var description_label : RichTextLabel = %DescriptionLabel
@onready var close_button : Button = %CloseButton
@onready var menu_buttons : BoxContainer = %MenuButtons
@onready var is_opened = visible

func _ready() -> void:
	update_content = update_content
	text = text
	close_button_text = close_button_text
	title = title
	if not close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)

func open() -> void:
	if is_opened:
		return
	is_opened = true
	show()

func close() -> void:
	if not is_opened:
		return
	is_opened = false
	hide()
	closed.emit()

func _handle_cancel_input() -> void:
	close()

func _unhandled_input(event : InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed("ui_cancel") and ui_cancel_closes:
		_handle_cancel_input()
		get_viewport().set_input_as_handled()

func _on_visibility_changed() -> void:
	if Engine.is_editor_hint(): return
	if is_visible_in_tree():
		open()
	elif not visible:
		close()

func _on_close_button_pressed() -> void:
	close()

func _exit_tree():
	if Engine.is_editor_hint(): return
	close()
