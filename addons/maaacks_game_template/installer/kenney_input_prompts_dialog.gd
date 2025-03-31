@tool
extends ConfirmationDialog

signal configuration_selected(index : int)

func _on_item_list_item_selected(index):
	configuration_selected.emit(index)
