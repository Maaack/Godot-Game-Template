@tool
class_name PaginatedCredits
extends Credits

const CENTER_OPEN_TAG := "[center]"
const CENTER_CLOSE_TAG := "[/center]"
const NOT_FOUND := -1
const FONT_SIZE_OPEN_TAG := "[font_size=%d]"

@onready var page_container : BoxContainer = %PageContainer
@onready var credits_label : CreditsLabel = %CreditsLabel
@onready var previous_button : Button = %PreviousButton
@onready var next_button : Button = %NextButton

@export_range(1, 4, 1.0) var visible_pages : int = 1 :
	set(value):
		visible_pages = value
		if is_inside_tree():
			_update_pages()
@export_range(0, 1, 0.001) var content_split : Array[float] = [1.0] :
	set(values):
		content_split = values
		if is_inside_tree():
			_update_pages()
@export_range(0, 10, 1, "or_greater") var current_page : int = 0 :
	set(value):
		current_page = value
		if is_inside_tree():
			_update_pages()

var page_texts : Array[String]

func _clear_pages() -> void:
	for child in page_container.get_children():
		child.queue_free()

func _remove_centering(centered_text: String) -> String:
	if centered_text.begins_with(CENTER_OPEN_TAG):
		centered_text = centered_text.substr(CENTER_OPEN_TAG.length())
	if centered_text.ends_with(CENTER_CLOSE_TAG):
		centered_text = centered_text.substr(0, centered_text.length()-CENTER_CLOSE_TAG.length())
	return centered_text

func _get_last_header(credits_text: String) -> int:
	var header_sizes: Array[int] = [
		credits_label.h1_font_size,
		credits_label.h2_font_size,
		credits_label.h3_font_size,
		credits_label.h4_font_size,
	]
	var last_header := NOT_FOUND
	var first_header := NOT_FOUND
	var last_header_iter := NOT_FOUND
	for font_size in header_sizes:
		last_header_iter += 1
		if credits_text.count(FONT_SIZE_OPEN_TAG % font_size) > 1:
			last_header = credits_text.rfind(FONT_SIZE_OPEN_TAG % font_size)
			first_header = credits_text.find(FONT_SIZE_OPEN_TAG % font_size)
			break
	if last_header_iter > 0:
		for iter in range(last_header_iter):
			var font_size := header_sizes[iter]
			var _rfind_result := credits_text.rfind(FONT_SIZE_OPEN_TAG % font_size)
			if _rfind_result > first_header and _rfind_result < last_header:
				last_header = _rfind_result
				break
	return last_header

func _update_buttons() -> void:
	previous_button.disabled = !(current_page > 0)
	next_button.disabled = !(current_page < page_texts.size() - (visible_pages))

func _update_pages() -> void:
	_clear_pages()
	page_texts.clear()
	var credits_text := credits_label.text
	credits_text = _remove_centering(credits_text)
	var last_character_position : int = 0
	for ratio in content_split:
		var character_ratio : int = credits_text.length() * ratio
		var split_credits_text := credits_text.substr(last_character_position, character_ratio)
		if credits_text.length() > split_credits_text.length() + last_character_position:
			var last_header_index := _get_last_header(split_credits_text)
			split_credits_text = split_credits_text.substr(0, last_header_index)
			last_character_position += last_header_index
		else:
			last_character_position += credits_text.length()
		page_texts.append(split_credits_text)
	for page_iter in range(visible_pages):
		var rich_text_label := RichTextLabel.new()
		rich_text_label.bbcode_enabled = true
		if current_page + page_iter >= page_texts.size(): break
		var split_credits_text = page_texts[current_page + page_iter]
		rich_text_label.text = "[center]%s[/center]" % [split_credits_text]
		rich_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rich_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		page_container.add_child(rich_text_label)
	_update_buttons()

func previous_page():
	if current_page <= 0 : return
	current_page -= 1

func next_page():
	if current_page >= page_texts.size() - (visible_pages) : return
	current_page += 1

func _ready() -> void:
	visible_pages = visible_pages
	previous_button.pressed.connect(previous_page)
	next_button.pressed.connect(next_page)
