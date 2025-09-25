@tool
extends RichTextLabel

const HEADING_STRING_REPLACEMENT = "$1[font_size=%d]$2[/font_size]"
const BOLD_HEADING_STRING_REPLACEMENT = "$1[b][font_size=%d]$2[/font_size][/b]"

@export_group("Font Sizes")
@export var h1_font_size: int
@export var h2_font_size: int
@export var h3_font_size: int
@export var h4_font_size: int
@export var h5_font_size: int
@export var h6_font_size: int
@export var bold_headings : bool
@export_group("Extra Options")
@export var disable_images : bool = false
@export var disable_urls : bool = false
@export var disable_bolds : bool = false

func regex_replace_imgs(markdown_text:String) -> String:
	var regex = RegEx.new()
	var match_string := "<img .* src=\"(.*)\" \\/>"
	var replace_string := ""
	if not disable_images:
		replace_string = "$1"
	regex.compile(match_string)
	return regex.sub(markdown_text, replace_string, true)

func regex_replace_urls(markdown_text:String) -> String:
	var regex = RegEx.new()
	var match_string := "(https:\\/\\/.*)($|\\s)"
	var replace_string := "$1"
	if not disable_urls:
		replace_string = "[url=$1]$1[/url]"
	regex.compile(match_string)
	return regex.sub(markdown_text, replace_string, true)

func regex_replace_bolds(markdown_text:String) -> String:
	var regex = RegEx.new()
	var match_string := "\\*\\*(.*)\\*\\*"
	var replace_string := "$1"
	if not disable_bolds:
		replace_string = "[b]$1[/b]"
	regex.compile(match_string)
	return regex.sub(markdown_text, replace_string, true)

func regex_replace_titles(markdown_text:String) -> String:
	var iter = 0
	var heading_font_sizes : Array[int] = [
		h1_font_size,
		h2_font_size,
		h3_font_size,
		h4_font_size,
		h5_font_size,
		h6_font_size]
	for heading_font_size in heading_font_sizes:
		iter += 1
		var regex = RegEx.new()
		var match_string : String = "([^#]|^)#{%d}\\s([^\n]*)" % iter
		var replace_string := HEADING_STRING_REPLACEMENT % [heading_font_size]
		if bold_headings:
			replace_string = BOLD_HEADING_STRING_REPLACEMENT % [heading_font_size]
		regex.compile(match_string)
		markdown_text = regex.sub(markdown_text, replace_string, true)
	return markdown_text

func from_release_notes(markdown_text : String) -> void:
	markdown_text = regex_replace_imgs(markdown_text)
	markdown_text = regex_replace_urls(markdown_text)
	markdown_text = regex_replace_bolds(markdown_text)
	markdown_text = regex_replace_titles(markdown_text)
	text = markdown_text

func _on_meta_clicked(meta: String) -> void:
	if meta.begins_with("https://"):
		var _err = OS.shell_open(meta)

func _ready() -> void:
	meta_clicked.connect(_on_meta_clicked)
