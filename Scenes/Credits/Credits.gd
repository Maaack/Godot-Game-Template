@tool
extends Control

signal end_reached

@onready var scroll_container = $ScrollContainer
@onready var rich_text_label = $ScrollContainer/VBoxContainer/RichTextLabel

@export_file("*.md") var attribution_file_path: String = "res://ATTRIBUTION.md": set = set_file_path
@export var h1_font: FontFile
@export var h2_font: FontFile
@export var h3_font: FontFile
@export var h4_font: FontFile
@export var current_speed: float = 1.0
@export var scroll_active : bool = true

var scroll_paused : bool = false

func load_file(file_path):
	var file_string = FileAccess.get_file_as_string(file_path)
	if file_string == null:
		print("File open error: %s" % FileAccess.get_open_error())
	return file_string

func regex_replace_urls(credits:String):
	var regex = RegEx.new()
	var match_string : String = "\\[([^\\]]*)\\]\\(([^\\)]*)\\)"
	var replace_string : String = "[url=$2]$1[/url]"
	regex.compile(match_string)
	return regex.sub(credits, replace_string, true)

func regex_replace_titles(credits:String):
	var iter = 0
	var heading_fonts : Array = [h1_font, h2_font, h3_font, h4_font]
	for heading_font in heading_fonts:
		if heading_font is FontFile:
			iter += 1
			var regex = RegEx.new()
			var match_string : String = "([^#])#{%d}\\s([^\n]*)" % iter
			var replace_string : String = "$1[font=%s]$2[/font]" % [heading_font.resource_path]
			regex.compile(match_string)
			credits = regex.sub(credits, replace_string, true)
	return credits

func set_file_path(file_path:String):
	attribution_file_path = file_path
	var text : String = load_file(attribution_file_path)
	if text == "":
		return
	# TODO: Figure out why this doesn't work anymore
	# text = text.right(text.find("\n")) # Trims first line "ATTRIBUTION"
	text = regex_replace_urls(text)
	text = regex_replace_titles(text)
	$ScrollContainer/VBoxContainer/RichTextLabel.text = "[center]%s[/center]" % [text]

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

func _scroll_container() -> void:
	if not scroll_active or scroll_paused or round(current_speed) == 0:
		return
	var previous_scroll = $ScrollContainer.scroll_vertical
	$ScrollContainer.scroll_vertical += round(current_speed)
	_check_end_reached(previous_scroll)

func _process(_delta):
	_scroll_container()

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
