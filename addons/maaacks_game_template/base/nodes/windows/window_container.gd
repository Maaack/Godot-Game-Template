@tool
class_name WindowContainer
extends PanelContainer

signal closed
signal opened

@export var ui_cancel_closes : bool = true

@export_group("Content")
@export var update_content : bool = false
@export_multiline var text : String :
	set(value):
		text = value
		if update_content and is_inside_tree():
			description_label.text = text

@export var close_button_text : String = "Close" :
	set(value):
		close_button_text = value
		if update_content and is_inside_tree():
			close_button.text = close_button_text

@export_subgroup("Title")
@export var title : String = "Menu" :
	set(value):
		title = value
		if update_content and is_inside_tree():
			title_label.text = title

@export_range(0, 1000, 1) var title_font_size : int = 16 :
	set(value):
		title_font_size = value
		if update_content and is_inside_tree():
			title_label.set("theme_override_font_sizes/font_size", title_font_size)

@export var title_visible : bool = true :
	set(value):
		title_visible = value
		if update_content and is_inside_tree():
			title_margin.visible = title_visible

@onready var content_container : Container = %ContentContainer
@onready var title_label : Label = %TitleLabel
@onready var title_margin : MarginContainer = %TitleMargin
@onready var description_label : RichTextLabel = %DescriptionLabel
@onready var close_button : Button = %CloseButton
@onready var menu_buttons : BoxContainer = %MenuButtons

func _ready() -> void:
	update_content = update_content
	text = text
	close_button_text = close_button_text
	title = title
	title_font_size = title_font_size
	title_visible = title_visible

func close() -> void:
	if not visible: return
	hide()
	closed.emit()

func _handle_cancel_input() -> void:
	close()

func _unhandled_input(event : InputEvent) -> void:
	if visible and event.is_action_released("ui_cancel") and ui_cancel_closes:
		_handle_cancel_input()
		get_viewport().set_input_as_handled()

func _on_close_button_pressed() -> void:
	close()

func show() -> void:
	super.show()
	opened.emit()

func _exit_tree():
	if Engine.is_editor_hint(): return
	close()
