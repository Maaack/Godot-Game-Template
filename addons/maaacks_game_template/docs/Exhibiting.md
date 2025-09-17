# Exhibiting your game

This page covers general best practices for exhibiting your game at conventions like PAX, Gamescom, etc. You generally don't want people to just close your game and do potentially malicious stuff on the computer, especially if it is your personal computer.

## General best practices

- Create a separate non-admin account on your computer and use that to run the game
- Disable the Alt-Tab shortcut in your operating system
	- Windows: Install PowerToys and use its Keyboard Manager to disable it

## In Godot

- Create a custom [feature tag](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html#custom-features) for a exhibition build
- Create a autoload script that blocks quitting, sets the window mode to exclusive fullscreen, and sets the mouse mode to confined
- Create custom actions for quitting the game
	- Hide these new actions by setting `show_all_actions` in the `scenes/menus/options_menu/input/input_options_menu.tscn` to `false` for the `InputActionsList` and `InputActionsTree` nodes
	- This could be any combination using at least two letters
- Hide all quit buttons using the feature tag
	- Quit buttons are by default in: Main Menu, Pause Menu, Overlaid Menu, Game Won Menu, Level Lost Menu
- Disable quitting by pressing `ui_cancel` in the end credits and main menu using the feature tag
- Disable the fullscreen toggle
- Create a exhibition build by adding the corresponding feature tag to a build preset 

Example Script: 
```swift
extends Node

var sum: float

func _ready() -> void:
	if not OS.has_feature("exhibition"):
		queue_free()
		return
	get_tree().set_auto_accept_quit(false)
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	get_window().always_on_top = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(delta: float) -> void:
	if (Input.is_action_pressed("exh_quit_one") and Input.is_action_pressed("exh_quit_two")):
		sum += delta
		if sum >= 3:
			get_tree().quit()
	else:
		sum = 0
```

Disabling a quit button is fairly easy, example from `end_credits.gd`:
```swift
if OS.has_feature("web") or OS.has_feature("exhibition"):
	%ExitButton.hide()
```

You can find a example Implementation [here](https://git.rostige-pipe.de/JaN0h4ck/fetziges-raetsel-spiel/commit/c65efc79e4460e88fecb8b8e81ce1edcfbbf9617#diff-32a77ee954ef131428f29b9ca647142bfaca06bf) (git.rostige-pipe.de)