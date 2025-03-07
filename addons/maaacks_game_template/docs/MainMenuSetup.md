# Main Menu Setup

These are instructions for further editing the menus. Basic instructions are available in the [README](/addons/maaacks_game_template/README.md#usage).

## Inheritance

Most example scenes in the template inherit from scenes in `addons`. This is useful for developing of the plugin, but often less useful for those using it.  When editing the example scenes, any nodes inherited from a parent scene are highlighted in yellow in the scene tree. Inherited nodes cannot be edited like native nodes. Therefore, it is recommended to first right-click on the root node, and select `Clear Inheritance`. You'll get a warning that this cannot be undone, but it's okay. You probably won't need to undo it, and if you do, there are solutions.

## Visual Placement

The positions and anchor presets of the UI elements can be adjusted to match most designs with ease. Buttons can be centered, right or left justfied, or arranged horizontally. Most visual UI elements are contained within `MarginContainer` and `Control` nodes that allow for fine-tuning of placement.

## Scene Structure
Some designs may require rearranging the nodes in the scene tree. This is easier once the inheritance to the parent scene is cleared. However, if editing `main_menu_with_animations.tscn`, keep in mind that there are animations, and moving elements outside of the animated containers may have undesired effects.

## 3D Background 
When adding a 3D background to the menu, it is recommended to use a `SubViewportContainer` in place of or right above the `BackgroundTextureRect`. Then add a `SubViewport` to it, and finally the 3D world node to that. This structure gives fine-tune control of scaling, allows for layering 3D views when they have transparency, and makes it easy to add a texture shader to the whole background.

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