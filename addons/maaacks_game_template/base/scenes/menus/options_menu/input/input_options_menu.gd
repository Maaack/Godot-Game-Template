@tool
class_name InputOptionsMenu
extends Control

const ALREADY_ASSIGNED_TEXT : String = "{key} already assigned to {action}."
const ONE_INPUT_MINIMUM_TEXT : String = "%s must have at least one key or button assigned."
const KEY_DELETION_TEXT : String = "Are you sure you want to remove {key} from {action}?"

@onready var assignment_placeholder_text = $KeyAssignmentDialog.dialog_text

var last_input_readable_name

func _horizontally_align_popup_labels():
	$KeyAssignmentDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$KeyDeletionDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$OneInputMinimumDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$AlreadyAssignedDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _ready():
	if Engine.is_editor_hint(): return
	_horizontally_align_popup_labels()

func _add_action_event():
	var last_input_event = $KeyAssignmentDialog.last_input_event
	last_input_readable_name = $KeyAssignmentDialog.last_input_text
	%InputActionsTree.add_action_event(last_input_readable_name, last_input_event)

func _on_key_assignment_dialog_canceled():
	%InputActionsTree.cancel_editing()

func _remove_action_event(item : TreeItem):
	%InputActionsTree.remove_action_event(item)

func _on_reset_button_pressed():
	$ConfirmationDialog.popup_centered()

func _on_key_deletion_dialog_confirmed():
	var editing_item = %InputActionsTree.editing_item
	if is_instance_valid(editing_item):
		_remove_action_event(editing_item)

func _on_key_assignment_dialog_confirmed():
	_add_action_event()

func _on_confirmation_dialog_confirmed():
	%InputActionsTree.reset()

func _on_input_actions_tree_add_button_clicked(action_name):
	$KeyAssignmentDialog.title = tr("Assign Key for {action}").format({action = action_name})
	$KeyAssignmentDialog.dialog_text = assignment_placeholder_text
	$KeyAssignmentDialog.get_ok_button().disabled = true
	$KeyAssignmentDialog.popup_centered()

func _on_input_actions_tree_remove_button_clicked(action_name, input_name):
	$KeyDeletionDialog.title = tr("Remove Key for {action}").format({action = action_name})
	$KeyDeletionDialog.dialog_text = tr(KEY_DELETION_TEXT).format({key = input_name, action = action_name})
	$KeyDeletionDialog.popup_centered()

func _on_input_actions_tree_already_assigned(action_name, input_name):
	$AlreadyAssignedDialog.dialog_text = tr(ALREADY_ASSIGNED_TEXT).format({key = input_name, action = action_name})
	$AlreadyAssignedDialog.popup_centered()

func _on_input_actions_tree_minimum_reached(action_name):
	$OneInputMinimumDialog.dialog_text = ONE_INPUT_MINIMUM_TEXT % action_name
	$OneInputMinimumDialog.popup_centered()
