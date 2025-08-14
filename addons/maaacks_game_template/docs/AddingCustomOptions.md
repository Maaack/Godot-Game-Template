# Adding Custom Options

This page covers adding new buttons, sliders, or editable text fields to the options menus that automatically persist between sessions.

## To the Menu
Custom options can be added to a menu without any code.

1.  Add an `option_control.tscn` node as a child to a container in a scene.
    1.  `slider_option_control.tscn` or `toggle_option_control.tscn` can be used if those types match requirements. In that case, skip step 6.
    2.  `list_option_control.tscn` and `vector_2_list_option_control.tscn` are also available, but more complicated. See the `ScreenResolution` example.
3.  Select the `OptionControl` node just added, to edit it in the inspector.
4.  Add an `Option Name`. This prefills the `Key` string.
5.  Select an `Option Section`. This prefills the `Section` string.
6.  Add any kind of `Button`, `Slider`, `LineEdit`, or `TextEdit` to the `OptionControl` node.
7.  Save the scene.

## To the Game
For options to have any effect outside of the menus, they will need to be referenced by their `key` and `section` from the `PlayerConfig` class.  
```
PlayerConfig.get_config(key, section)
```  

For example, here is how to get the player's desired input sensitivity for controlling a player camera.  
```
var mouse_sensitivity : float = PlayerConfig.get_config(AppSettings.INPUT_SECTION, "MouseSensitivity", 1.0)
var joypad_sensitivity : float = PlayerConfig.get_config(AppSettings.INPUT_SECTION, "JoypadSensitivity", 1.0)
```

## Validation
 Validate the values being stored in your local `player_config.cfg` file.  
1.  Refer to [Accessing Persistent User Data User](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#accessing-persistent-user-data-user) to find Godot user data on your machine.
2.  Find the directory that matches your project's name.  
3.  Open `player_config.cfg` (should be in the top directory of the project).
4.  Find the section by the section name in brackets, and the key name followed by an equals.

For example, here is how the player's desired input sensitivity could appear in the config file.

```
[InputSettings]

MouseSensitivity=1.05
JoypadSensitivity=0.95
```

> [!NOTE]  
> Some settings may not appear until they have been customized.
