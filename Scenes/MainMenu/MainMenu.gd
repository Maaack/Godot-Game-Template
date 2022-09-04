extends Control


export(String) var version_name = '0.0.0'
export(String, FILE, "*.tscn") var game_scene : String

var animation_state_machine : AnimationNodeStateMachinePlayback
var sub_menu

func load_scene(scene_path : String):
	SceneLoader.load_scene(scene_path)

func play_game():
	GameLog.game_played(version_name)
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

func _on_PlayButton_pressed():
	play_game()

func _on_TutorialButton_pressed():
	pass

func _on_OptionsButton_pressed():
	_open_sub_menu($OptionsMenu)

func _on_CreditsButton_pressed():
	_open_sub_menu($CreditsContainer/Credits)
	$CreditsContainer/Credits.reset()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_BackButton_pressed():
	_close_sub_menu()

func intro_done():
	$MenuAnimationTree.set("parameters/conditions/intro_done", true)

func _input(event):
	if animation_state_machine.get_current_node() == "Intro" and \
		(event is InputEventMouseButton or event is InputEventKey):
		intro_done()

func _setup_for_web():
	if OS.has_feature("web"):
		$MarginContainer/Main/ButtonContainer/Exit.disabled = true

func 	_setup_version_name():
	$"%VersionNameLabel".text = "v%s" % version_name

func _ready():
	_setup_for_web()
	_setup_version_name()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
