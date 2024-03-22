@tool
extends Control

signal end_reached

@onready var scroll_container = $ScrollContainer
@onready var rich_text_label = $ScrollContainer/VBoxContainer/RichTextLabel

@export_file("*.md") var attribution_file_path: String = "res://ATTRIBUTION.md"
@export var h1_font_size: int
@export var h2_font_size: int
@export var h3_font_size: int
@export var h4_font_size: int
@export var current_speed: float = 1.0
@export var scroll_active : bool = true

var scroll_paused : bool = false

func load_file(file_path) -> String:
	var file_string = FileAccess.get_file_as_string(file_path)
	if file_string == null:
		push_warning("File open error: %s" % FileAccess.get_open_error())
		return ""
	return file_string

func regex_replace_urls(credits:String):
	var regex = RegEx.new()
	var match_string : String = "\\[([^\\]]*)\\]\\(([^\\)]*)\\)"
	var replace_string : String = "[url=$2]$1[/url]"
	regex.compile(match_string)
	return regex.sub(credits, replace_string, true)

func regex_replace_titles(credits:String):
	var iter = 0
	var heading_font_sizes : Array[int] = [h1_font_size, h2_font_size, h3_font_size, h4_font_size]
	for heading_font_size in heading_font_sizes:
		iter += 1
		var regex = RegEx.new()
		var match_string : String = "([^#])#{%d}\\s([^\n]*)" % iter
		var replace_string : String = "$1[font_size=%d]$2[/font_size]" % [heading_font_size]
		regex.compile(match_string)
		credits = regex.sub(credits, replace_string, true)
	return credits

func _update_text_from_file():
	var text : String = load_file(attribution_file_path)
	if text == "":
		return
	text = text.right(-text.find("\n")) # Trims first line "ATTRIBUTION"
	text = regex_replace_urls(text)
	text = regex_replace_titles(text)
	$ScrollContainer/VBoxContainer/RichTextLabel.text = "[center]%s[/center]" % [text]

func set_file_path(file_path:String):
	attribution_file_path = file_path
	_update_text_from_file()

func set_header_and_footer():
	$ScrollContainer/VBoxContainer/HeaderSpace.custom_minimum_size.y = size.y
	$ScrollContainer/VBoxContainer/FooterSpace.custom_minimum_size.y = size.y
	$ScrollContainer/VBoxContainer/RichTextLabel.custom_minimum_size.x = size.x

func reset():
	$ScrollContainer.scroll_vertical = 0
	scroll_active = true
	set_header_and_footer()

func _ready():
	set_file_path(attribution_file_path)
	set_header_and_footer()

func _end_reached():
	scroll_active = false
	emit_signal("end_reached")

func _check_end_reached(previous_scroll):
	if previous_scroll != $ScrollContainer.scroll_vertical:
		return
	_end_reached()

func _scroll_container(amount : float) -> void:
	if not scroll_active or scroll_paused or round(amount) == 0:
		return
	var previous_scroll = $ScrollContainer.scroll_vertical
	$ScrollContainer.scroll_vertical += round(amount)
	_check_end_reached(previous_scroll)

func _process(_delta):
	if Engine.is_editor_hint():
		return
	var input_axis = Input.get_axis("ui_up", "ui_down")
	if input_axis != 0:
		_scroll_container(10 * input_axis)
	else:
		_scroll_container(current_speed)

func _on_RichTextLabel_gui_input(event):
	if event is InputEventMouseButton:
		scroll_paused = true
		_start_scroll_timer()

func _start_scroll_timer():
	var timer = get_tree().create_timer(1.5)
	await timer.timeout
	set_header_and_footer()
	scroll_paused = false

func _on_RichTextLabel_meta_clicked(meta:String):
	if meta.begins_with("https://"):
		var _err = OS.shell_open(meta)
