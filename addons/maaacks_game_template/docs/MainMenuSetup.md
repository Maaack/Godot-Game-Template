# Main Menu Setup

These are instructions for further editing the menus. Basic instructions are available in the [README](/addons/maaacks_game_template/README.md#usage).

## Selecting a Menu
The path to the main menu is set in the `AppConfig` autoload. `main_menu_with_animations.tscn` is the main menu scene used by default. Open the `app_config.tscn` scene, inspect the root note, and edit the `Main Menu Scene Path` to the desired scene.

Alternatively, the main menu path can be set directly in the following scenes:

* `opening.tscn`  
* `pause_menu_layer.tscn`  
* `game_ui.tscn` (`level_manager.gd`)  
* `end_credits.tscn`  

## Clear Inheritance

Most example scenes in the template inherit from scenes in `addons`. Nodes inherited from a parent scene are highlighted in yellow (by default) in the scene tree. Inherited nodes cannot be edited like native nodes. Therefore, it is recommended to first right-click on the root node, and select `Clear Inheritance`. You'll get a warning that this cannot be undone, but it's okay. The inheritance is useful when developing the plugin itself, but much less so for a game.

## Title and Subtitle

The title will automatically update from the project's name. If a custom title is desired, select the `TitleLabel` node, set `Auto Update` to false, and set `Text` to the custom title. The `SubTitleLabel` can be customized with the `Text` field as well, or hidden entirely.

## Visual Placement

The positions and anchor presets of the UI elements can be adjusted to match most designs with ease. Buttons can be centered, right or left justfied, or arranged horizontally. Most visual UI elements are contained within `MarginContainer` and `Control` nodes that allow for fine-tuning of placement.

## Scene Structure
Some designs may require rearranging the nodes in the scene tree. This is easier once the inheritance to the parent scene is cleared. However, if editing `main_menu_with_animations.tscn`, keep in mind that there are animations, and moving elements outside of the animated containers may have undesired effects.

## 3D Background 
If adding a 3D background to the menu, a 3D world node in the scene tree should normally display behind the control nodes. Using a `SubViewport` with the 3D world node attached to that adds a degree of control over scaling. Adding that into a `SubViewportContainer` provides even more fine-tune control of layering and makes it easy to add a texture shader to the whole background.

## Level Select

A basic level select scene is available to add to the menu. In `main_menu_with_animations.tscn`, click the root `MainMenu` mode and set `Level Select Packed Scene` to `level_select_menu.tscn`. The button will appear on the main menu when the player has reached the second level.  

Levels can be added to the menu by inspecting the `SceneLister` and either selecting a directory to automatically read scene files from, or populating the files array manually.

## Theming
It is recommended to have a custom theme for a project. Create a theme resource file or use one of the ones provided with the template and set it as the custom theme in the project settings. Any changes made to the theme file will then apply automatically to the whole project.

The main UI elements that are used throughout the project that require theming for customization are:
- Button
- Label
- PanelContainer
- ProgressBar
- TabContainer
- Tree