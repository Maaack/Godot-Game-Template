@tool
extends Control

const ALREADY_ASSIGNED_TEXT : String = "{key} already assigned to {action}."
const ONE_INPUT_MINIMUM_TEXT : String = "%s must have at least one key or button assigned."
const KEY_DELETION_TEXT : String = "Are you sure you want to remove {key} from {action}?"

@onready var input_actions_list = %InputActionsList
@onready var input_actions_tree = %InputActionsTree
@onready var key_deletion_confirmation = %KeyDeletionConfirmation
@onready var reset_confirmation = %ResetConfirmation
@onready var one_input_minimum_message = %OneInputMinimumMessage
@onready var already_assigned_message = %AlreadyAssignedMessage
@onready var key_assignment_window = %KeyAssignmentWindow
@onready var assignment_placeholder_text = %KeyAssignmentWindow.text
@onready var reset_button = %ResetButton

@export_enum("List", "Tree") var remapping_mode : int = 0 :
	set(value):
		remapping_mode = value
		if is_inside_tree():
			match(remapping_mode):
				0:
					input_actions_list.show()
					input_actions_tree.hide()
				1:
					input_actions_list.hide()
					input_actions_tree.show()

var last_input_readable_name

func _ready() -> void:
	remapping_mode = remapping_mode
	input_actions_tree.already_assigned.connect(_on_input_actions_list_already_assigned)
	key_assignment_window.confirmed.connect(_on_key_assignment_window_confirmed)
	key_deletion_confirmation.confirmed.connect(_on_key_deletion_confirmation_confirmed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	reset_confirmation.confirmed.connect(_on_reset_confirmation_confirmed)

func _add_action_event() -> void:
	var last_input_event = key_assignment_window.last_input_event
	last_input_readable_name = key_assignment_window.last_input_text
	match(remapping_mode):
		0:
			input_actions_list.add_action_event(last_input_readable_name, last_input_event)
		1:
			input_actions_tree.add_action_event(last_input_readable_name, last_input_event)

func _remove_action_event(item : TreeItem) -> void:
	input_actions_tree.remove_action_event(item)

func _on_reset_button_pressed() -> void:
	reset_confirmation.show()

func _on_key_deletion_confirmation_confirmed() -> void:
	var editing_item = input_actions_tree.editing_item
	if is_instance_valid(editing_item):
		_remove_action_event(editing_item)

func _on_key_assignment_window_confirmed() -> void:
	_add_action_event()

func _open_key_assignment_window(action_name : String, readable_input_name : String = assignment_placeholder_text) -> void:
	key_assignment_window.title = tr("Assign Key for {action}").format({action = action_name})
	key_assignment_window.text = readable_input_name
	key_assignment_window.confirm_button.disabled = true
	key_assignment_window.show()

func _on_input_actions_tree_add_button_clicked(action_name) -> void:
	_open_key_assignment_window(action_name)

func _on_input_actions_tree_remove_button_clicked(action_name, input_name) -> void:
	key_deletion_confirmation.title = tr("Remove Key for {action}").format({action = action_name})
	key_deletion_confirmation.text = tr(KEY_DELETION_TEXT).format({key = input_name, action = action_name})
	key_deletion_confirmation.show()

func _popup_already_assigned(action_name, input_name) -> void:
	already_assigned_message.text = tr(ALREADY_ASSIGNED_TEXT).format({key = input_name, action = action_name})
	already_assigned_message.show()

func _popup_minimum_reached(action_name : String) -> void:
	one_input_minimum_message.text = ONE_INPUT_MINIMUM_TEXT % action_name
	one_input_minimum_message.show()

func _on_input_actions_tree_already_assigned(action_name, input_name) -> void:
	_popup_already_assigned.call_deferred(action_name, input_name)

func _on_input_actions_tree_minimum_reached(action_name) -> void:
	_popup_minimum_reached.call_deferred(action_name)

func _on_input_actions_list_already_assigned(action_name, input_name) -> void:
	_popup_already_assigned.call_deferred(action_name, input_name)

func _on_input_actions_list_minimum_reached(action_name) -> void:
	_popup_minimum_reached.call_deferred(action_name)

func _on_input_actions_list_button_clicked(action_name, readable_input_name) -> void:
	_open_key_assignment_window(action_name, readable_input_name)

func _on_reset_confirmation_confirmed() -> void:
	match(remapping_mode):
		0:
			input_actions_list.reset()
		1:
			input_actions_tree.reset()
