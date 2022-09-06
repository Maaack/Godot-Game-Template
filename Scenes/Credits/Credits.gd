extends Control


signal end_reached

onready var scroll_container = $ScrollContainer
onready var rich_text_label = $ScrollContainer/VBoxContainer/RichTextLabel
onready var scroll_timer = $ScrollResetTimer

export(String) var attribution_file_path : String = "res://ATTRIBUTION.md" setget set_file_path
export(DynamicFont) var h1_font
export(DynamicFont) var h2_font
export(DynamicFont) var h3_font
export(DynamicFont) var h4_font
export(float) var current_speed : float = 1.0

var is_scrolling : bool = true

func load_file(file_path):
	var file : File = File.new()
	var open_error : int = file.open(file_path, File.READ)
	if open_error:
		print("load file failed with error %d" % open_error)
	var text : String = file.get_as_text()
	file.close()
	return text

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
		if heading_font is DynamicFont:
			iter += 1
			var regex = RegEx.new()
			var match_string : String = "([^#])#{%d}\\s([^\n]*)" % iter
			var replace_string : String = "$1[font=%s]$2[/font]" % [heading_font.resource_path]
			regex.compile(match_string)
			credits = regex.sub(credits, replace_string, true)
	return credits

func set_file_path(value:String):
	var text : String = load_file(value)
	if text == "":
		return
	text = text.right(text.find("\n")) # Trims first line "ATTRIBUTION"
	text = regex_replace_urls(text)
	text = regex_replace_titles(text)
	$ScrollContainer/VBoxContainer/RichTextLabel.bbcode_text = "[center]%s[/center]" % [text]

func set_header_and_footer():
	$ScrollContainer/VBoxContainer/HeaderSpace.rect_min_size.y = rect_size.y
	$ScrollContainer/VBoxContainer/FooterSpace.rect_min_size.y = rect_size.y
	$ScrollContainer/VBoxContainer/RichTextLabel.rect_min_size.x = rect_size.x

func reset():
	$ScrollContainer.scroll_vertical = 0
	set_header_and_footer()

func _ready():
	set_file_path(attribution_file_path)
	set_header_and_footer()
	set_process(false)

func _check_end_reached(previous_scroll):
	if previous_scroll != $ScrollContainer.scroll_vertical:
		return
	set_process(false)
	emit_signal("end_reached")

func _scroll_container() -> void:
	if not is_scrolling or round(current_speed) == 0:
		return
	var previous_scroll = $ScrollContainer.scroll_vertical
	$ScrollContainer.scroll_vertical += round(current_speed)
	_check_end_reached(previous_scroll)

func _process(_delta):
	_scroll_container()

func _on_RichTextLabel_gui_input(event):
	if event is InputEventMouseButton:
		is_scrolling = false
		scroll_timer.start()

func _on_ScrollResetTimer_timeout():
	set_header_and_footer()
	is_scrolling = true

func _on_RichTextLabel_meta_clicked(meta:String):
	if meta.begins_with("https://"):
		var _err = OS.shell_open(meta)
