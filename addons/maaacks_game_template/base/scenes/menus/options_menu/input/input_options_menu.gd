@tool
class_name InputOptionsMenu
extends Control

const ALREADY_ASSIGNED_TEXT : String = "{key} already assigned to {action}."
const ONE_INPUT_MINIMUM_TEXT : String = "%s must have at least one key or button assigned."
const KEY_DELETION_TEXT : String = "Are you sure you want to remove {key} from {action}?"

@export_enum("List", "Tree") var remapping_mode : int = 0 :
	set(value):
		remapping_mode = value
		if is_inside_tree():
			match(remapping_mode):
				0:
					%InputActionsList.show()
					%InputActionsTree.hide()
				1:
					%InputActionsList.hide()
					%InputActionsTree.show()

@onready var assignment_placeholder_text = $KeyAssignmentDialog.dialog_text

var last_input_readable_name

func _horizontally_align_popup_labels() -> void:
	$KeyAssignmentDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$KeyDeletionDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$OneInputMinimumDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$AlreadyAssignedDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$ResetConfirmationDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _ready() -> void:
	remapping_mode = remapping_mode
	if Engine.is_editor_hint(): return
	_horizontally_align_popup_labels()

func _add_action_event() -> void:
	var last_input_event = $KeyAssignmentDialog.last_input_event
	last_input_readable_name = $KeyAssignmentDialog.last_input_text
	match(remapping_mode):
		0:
			%InputActionsList.add_action_event(last_input_readable_name, last_input_event)
		1:
			%InputActionsTree.add_action_event(last_input_readable_name, last_input_event)

func _remove_action_event(item : TreeItem) -> void:
	%InputActionsTree.remove_action_event(item)

func _on_reset_button_pressed() -> void:
	$ResetConfirmationDialog.popup_centered()

func _on_key_deletion_dialog_confirmed() -> void:
	var editing_item = %InputActionsTree.editing_item
	if is_instance_valid(editing_item):
		_remove_action_event(editing_item)

func _on_key_assignment_dialog_confirmed() -> void:
	_add_action_event()

func _open_key_assignment_dialog(action_name : String, readable_input_name : String = assignment_placeholder_text) -> void:
	$KeyAssignmentDialog.title = tr("Assign Key for {action}").format({action = action_name})
	$KeyAssignmentDialog.dialog_text = readable_input_name
	$KeyAssignmentDialog.get_ok_button().disabled = true
	$KeyAssignmentDialog.popup_centered()

func _on_input_actions_tree_add_button_clicked(action_name) -> void:
	_open_key_assignment_dialog(action_name)

func _on_input_actions_tree_remove_button_clicked(action_name, input_name) -> void:
	$KeyDeletionDialog.title = tr("Remove Key for {action}").format({action = action_name})
	$KeyDeletionDialog.dialog_text = tr(KEY_DELETION_TEXT).format({key = input_name, action = action_name})
	$KeyDeletionDialog.popup_centered()

func _popup_already_assigned(action_name, input_name) -> void:
	$AlreadyAssignedDialog.dialog_text = tr(ALREADY_ASSIGNED_TEXT).format({key = input_name, action = action_name})
	$AlreadyAssignedDialog.popup_centered.call_deferred()

func _popup_minimum_reached(action_name : String) -> void:
	$OneInputMinimumDialog.dialog_text = ONE_INPUT_MINIMUM_TEXT % action_name
	$OneInputMinimumDialog.popup_centered.call_deferred()

func _on_input_actions_tree_already_assigned(action_name, input_name) -> void:
	_popup_already_assigned(action_name, input_name)

func _on_input_actions_tree_minimum_reached(action_name) -> void:
	_popup_minimum_reached(action_name)

func _on_input_actions_list_already_assigned(action_name, input_name) -> void:
	_popup_already_assigned(action_name, input_name)

func _on_input_actions_list_minimum_reached(action_name) -> void:
	_popup_minimum_reached(action_name)

func _on_input_actions_list_button_clicked(action_name, readable_input_name) -> void:
	_open_key_assignment_dialog(action_name, readable_input_name)

func _on_reset_confirmation_dialog_confirmed() -> void:
	match(remapping_mode):
		0:
			%InputActionsList.reset()
		1:
			%InputActionsTree.reset()
