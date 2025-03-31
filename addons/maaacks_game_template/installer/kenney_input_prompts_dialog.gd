@tool
extends ConfirmationDialog

const SHORT_DESCRIPTION : String = "Choose a style for icons in the input remapping menu. This style can be changed later."

signal configuration_selected(index : int)

func _on_item_list_item_selected(index):
	configuration_selected.emit(index)

func set_short_description():
	%Label.text = SHORT_DESCRIPTION
