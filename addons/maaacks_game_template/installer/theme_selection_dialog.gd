extends ConfirmationDialog

signal theme_selected(theme_file: String)

func _fill_with_themes():
	for file in %FileLister.files:
		if file is String:
			var readable_name = file.get_file().get_basename().capitalize()
			%ItemList.add_item(readable_name)

func _ready():
	_fill_with_themes()

func _on_item_list_item_selected(index):
	if index < %FileLister.files.size():
		var file = %FileLister.files[index]
		theme_selected.emit(file)
