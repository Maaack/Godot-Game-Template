@tool
extends ConfirmationDialog

signal theme_selected(theme_file: String)

func _fill_with_themes():
	%ItemList.clear()
	for file in %FileLister.files:
		if file is String:
			var readable_name = file.get_file().get_basename().capitalize()
			%ItemList.add_item(readable_name)

func _ready():
	_fill_with_themes()
	get_ok_button().disabled = true

func _preview_theme(theme_file: String):
	var theme_resource : Theme = load(theme_file)
	if theme_resource == null: return
	%ThemePreviewContainer.theme = theme_resource

func _on_item_list_item_selected(index):
	get_ok_button().disabled = false
	if index < %FileLister.files.size():
		var file = %FileLister.files[index]
		_preview_theme(file)
		theme_selected.emit(file)
