# Exhibiting Games

This page covers general best practices for exhibiting your game at conventions like PAX, Gamescom, etc. You generally don't want people to just close your game and do potentially malicious stuff on the computer, especially if it is your personal computer.

## General Best Practices

- Create a separate non-admin account on your computer and use that to run the game.
- Disable the Alt-Tab shortcut in your operating system.
	- Windows: Install PowerToys and use its Keyboard Manager to disable it.

## In Godot

- Create a custom [feature tag](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html#custom-features) for an exhibition build.
- Create a autoload script that blocks quitting, sets the window mode to exclusive fullscreen, and sets the mouse mode to confined.
- Create custom actions for quitting the game.
	- These can be a combination of letters that are unlikely to be pressed by a player during the game.
	- Scripting an input timer can avoid an accidental press by a player from quitting the game.
	- These should be kept hidden from the player.
- Create a exhibition build by adding the corresponding feature tag to a build preset.

### In the Game Template
- Hide the custom quit action(s) by setting `show_all_actions` to `false` for the `InputActionsList` and `InputActionsTree` nodes.  
Update: Input Options Menu
- Disable quitting with the `ui_cancel` action using the feature tag.  
Update:
	- Main Menu
	- End Credits
- Hide all quit buttons using the feature tag.  
Update:
	- Main Menu
	- Pause Menu
	- Overlaid Menu
	- Game Won Menu
	- Level Lost Menu
- Disable the fullscreen toggle.  
Update: Video Options Menu


### Example

Autoload Script: 
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

Disable a quit button by checking for the additional feature flag.  
Example from `end_credits.gd`:
```swift
if OS.has_feature("web") or OS.has_feature("exhibition"):
	%ExitButton.hide()
```

An example implementation is available at [git.rostige-pipe.de](https://git.rostige-pipe.de/JaN0h4ck/fetziges-raetsel-spiel/commit/c65efc79e4460e88fecb8b8e81ce1edcfbbf9617#diff-32a77ee954ef131428f29b9ca647142bfaca06bf).