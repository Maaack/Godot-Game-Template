# Game Scene Setup

When setting up a game scene, it is useful to refer to the `game_scene/game_ui.tscn` included in the examples.  

There are a few parts to setting up a basic game scene, as done in the `GameUI` example used in the template.

## Pausing
The `pause_menu_controller.gd` script may be attached to a node in the scene tree. Any empty `Node` is fine. Selecting the node should then allow for setting the `pause_menu_packed` value in the inspector. Set it to the `pause_menu.tscn` scene and save.

This should be enough to capture when the `ui-cancel` input action is pressed in-game. On keyboards, this is commonly the `Esc` key.

## Level Loading
Some level loading scripts are provided with the examples. They load levels in order from a list, or dynamically by file paths. It is called from a `LevelListManager`.

```
func _load_next_level():
	level_list_loader.advance_and_load_level()
```

A `LevelLoader` must be provided with a `level_container` in the scene. Levels will get added to and removed from this node. The example uses the `SubViewport`, but any leaf node (ie. node without children) in the scene should work.

An additional loading screen in the scene can show progress of loading levels, and is toggled by the `LevelListManager`.

```
func _on_level_loader_level_load_started():
	if level_loading_screen:
		level_loading_screen.reset()
```

Level Loading is not required if the entire game takes place in one scene.  

## Background Music
`BackgroundMusicPlayer`'s are `AudioStreamPlayer`'s with `autoplay` set to `true` and `audio_bus` set to "Music". These will automatically be recognized by the `ProjectMusicController` with the default settings, and allow for blending between tracks.

A `BackgroundMusicPlayer` can be added to the game scene, but the level scenes are typically a better place for them, as that allows for tracks to vary by level.

## SubViewports
The game example has the levels loaded into a `SubViewport` node, contained within a `SubViewportContainer`. This has a couple of advantages.

- Separates elements intended to appear inside the game world from those intended to appear on a layer above it. 
- Allows setting a fixed resolution for the game, like pixel art games.
- Allows setting rendering setting, like anti-aliasing.
- Supports easily adding visual effects with shaders on the `SubViewportContainer`.
- Visual effects can be added to the game world without hurting the readability of the UI.

It has some disadvantages, as well.

- Requires enabling Audio Listeners to hear audio from the game world.
- Extra processing overhead for the viewport layer.

## Read Inputs
Generally, any game is going to require reading some inputs from the player. Where in the scene hierarchy the reading occurs is best answered with simplicity.  

If the game involves moving a player character, then the inputs for movements could be read by a `player_character.gd` script overriding the `_process(delta)` or `_input(event)` methods.  

If the game involves sending commands to multiple units, then those inputs probably should be read by a `game_ui.gd` script, that then propagates those calls further down the chain.  

## Win & Lose Screens
The example includes win and lose screens. These are triggered by the `LevelListManager` when a level is won or lost.

```
func _load_level_complete_screen_or_next_level():
	if level_won_scene:
		var instance = level_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		...
	else:
		_load_next_level()
```
Winning on the last level results in loading a win screen or ending for the game.

```
func _on_level_won():
	if level_list_loader.is_on_last_level():
		_load_win_screen_or_ending()
	else:
		_load_level_complete_screen_or_next_level()
```
 The `LevelListManager` will need to be linked to direct back to the main menu and forward to `end_credits.tscn`.