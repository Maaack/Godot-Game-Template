extends Node
class_name EquipmentComponent

@export_group("Dependencies")
@export var usable: UsableComponent = null

func on_signal_received() -> void:
	usable.use()
