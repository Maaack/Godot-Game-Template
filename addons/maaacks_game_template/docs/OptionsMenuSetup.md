# Options Menu Setup

These instructions cover customizing the options menus.

User choices persist in a user config file, and are loaded when the app opens.

## Removing Options

By default, more options are provided than are generally needed. It is recommended to hide or remove the extras.

1.  Open `master_options_menu_with_tabs.tscn`.  
2.  Delete nodes of option scenes that do not apply to the game.  
    1.  `Controls` is usually useful for supporting input remapping.
    2.  `Inputs` can be removed unless supporting a 3D camera.
    3.  `Audio` is usually useful.
    4.  `Video` is usually useful.
    5.  `Game` can be removed unless supporting persistant game state.
3.  Open `mini_options_menu.tscn` or `[audio|visual|input|game]_options_menu.tscn` scenes to edit their options.  
4.  If an individual option is not desired, it can be hidden or removed entirely (sometimes with some additional work).  

## Adding Options

New buttons, sliders, or editable text fields can be added that automatically persist user choices between sessions.

### To the Menu
Custom options can be added to a menu without any code.

1.  Add an `option_control.tscn` node as a child to a container in a scene.
    1.  `slider_option_control.tscn` or `toggle_option_control.tscn` can be used if those types match requirements. In that case, skip step 6.
    2.  `list_option_control.tscn` and `vector_2_list_option_control.tscn` are also available, but more complicated. See the `ScreenResolution` example.
3.  Select the `OptionControl` node just added, to edit it in the inspector.
4.  Add an `Option Name`. This prefills the `Key` string.
5.  Select an `Option Section`. This prefills the `Section` string.
6.  Add any kind of `Button`, `Slider`, `LineEdit`, or `TextEdit` to the `OptionControl` node.
7.  Save the scene.

### To the Game
For options to have any effect outside of the menus, they will need to be referenced by their `key` and `section` from the `PlayerConfig` class.  
```
PlayerConfig.get_config(key, section)
```  

For example, here is how to get the player's desired input sensitivity for controlling a player camera.  
```
var mouse_sensitivity : float = PlayerConfig.get_config(AppSettings.INPUT_SECTION, "MouseSensitivity", 1.0)
var joypad_sensitivity : float = PlayerConfig.get_config(AppSettings.INPUT_SECTION, "JoypadSensitivity", 1.0)
```

### Validation
Validate the values being stored in your local `player_config.cfg` file.  
1.  Navigate to `Project > Open User Data Folder`.
2.  Open `player_config.cfg`.
3.  Find the section by the section name in brackets, and the key name followed by an equals.

For example, here is how the player's desired input sensitivity could appear in the config file.

```
[InputSettings]

MouseSensitivity=1.05
JoypadSensitivity=0.95
```

> [!NOTE]  
> Some settings may not appear until they have been customized.
