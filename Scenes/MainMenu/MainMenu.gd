extends Control


@export_file("*.tscn") var game_scene : String
@export var version_name: String = '0.0.0'

var animation_state_machine : AnimationNodeStateMachinePlayback
var sub_menu

func load_scene(scene_path : String):
	SceneLoader.load_scene(scene_path)

func play_game():
	GameLog.game_started()
	SceneLoader.load_scene(game_scene)

func _open_sub_menu(menu : Control):
	menu.visible = true
	sub_menu = menu
	animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu():
	if sub_menu == null:
		return
	animation_state_machine.travel("MainMenuOpen")
	sub_menu.visible = false
	sub_menu = null
	animation_state_machine.travel("MainMenuOpen")

func intro_done():
	animation_state_machine.travel("MainMenuOpen")

func _input(event):
	if animation_state_machine.get_current_node() == "Intro" and \
		(event is InputEventMouseButton or event is InputEventKey):
		intro_done()

func _setup_for_web():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _setup_version_name():
	AppLog.version_opened(version_name)
	$"%VersionNameLabel".text = "v%s" % version_name

func _ready():
	_setup_for_web()
	_setup_version_name()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	if game_scene.is_empty():
		%PlayButton.hide()

func _on_play_button_pressed():
	play_game()

func _on_options_button_pressed():
	_open_sub_menu(%MasterOptionsMenu)

func _on_credits_button_pressed():
	_open_sub_menu(%Credits)
	%Credits.reset()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_credits_end_reached():
	_close_sub_menu()

func _on_back_button_pressed():
	_close_sub_menu()
