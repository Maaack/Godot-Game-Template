@tool
extends ConfirmationDialog

signal theme_selected(theme_file: String)

@export_dir var theme_directories : Array[String] :
	set(value):
		theme_directories = value
		if is_inside_tree():
			%FileLister.directories = theme_directories
			_fill_with_themes()

func _fill_with_themes() -> void:
	%ItemList.clear()
	for file in %FileLister.files:
		if file is String:
			var readable_name = file.get_file().get_basename().capitalize()
			%ItemList.add_item(readable_name)

func _ready() -> void:
	get_ok_button().disabled = true

func _preview_theme(theme_file: String) -> void:
	var theme_resource : Theme = load(theme_file)
	if theme_resource == null: return
	%ThemePreviewContainer.theme = theme_resource

func _on_item_list_item_selected(index) -> void:
	get_ok_button().disabled = false
	if index < %FileLister.files.size():
		var file = %FileLister.files[index]
		_preview_theme(file)
		theme_selected.emit(file)
