# Godot Game Template
For Godot 4.2

This template has a main menu, pause menu, and credits scene. It supports basic accessibility features like input rebinding, sound, and video controls.

[Example on itch.io](https://maaack.itch.io/godot-game-template)

![Main Menu](/Media/Screenshot-2-1.png)  
![Key Rebinding](/Media/Screenshot-2-2.png)  
![Key Rebinding](/Media/Screenshot-2-4.png)  

## Use Case
Setup menus and accessibility features in about 15 minutes.

The core components can support a larger project, but the template was originally built to support smaller projects and game jams.

## Features

### Base

The `base/` folder holds the core components of the menus application.

-   Main Menu    
-   Options Menus
-   Credits
-   Loading Screen
-   Persistent Settings
-   Simple Config Interface
-   Keyboard/Mouse Support
-   Gamepad Support
-   Centralized UI Sound Control

### Extras

The `extras/` folder holds components that extend the core application.

-   Pause Menu
-   Opening Scene
-   Success & Failure Scenes
-   Logging Scripts
-   Autoload Scenes
 
### Examples 

The `examples/` folder contains an example project using inherited scenes from the `base/` and `extras/`.

-   Example Game Scene
-   Level Advancement
-   End Credits
-   Shader Pre-caching
-   Additional Inherited Scenes:
    -   `OptionsMenuWithReset.tscn`
    -   `MasterOptionsMenuWithGameTab.tscn`
    -   `MainMenuWithAnimations.tscn` 
    -   `PauseMenuWithScenes.tscn`
    -   `InitAppWithOpening.tscn`
    -   `LoadingScreenWithShaderCaching.tscn`

### How it Works
- `InitApp.tscn` is the project's main scene. It loads all the configuration settings from the config file (if it exists) into game and sets the loading screen. It then loads the next scene (`Opening.tscn` or `MainMenu.tscn`).  
- `Opening.tscn` is a simple scene for fading in/out a few images at the start of the game. It then loads the next scene (`MainMenu.tscn`).  
- `MainMenu.tscn` is where a player can start the game, change settings, watch credits, or quit. It can link to the path of a game scene to play, and the packed scene of an options menu to use.  
- `SceneLoader.gd` is an autoload script. It can load scenes in the background or with a loading screen (`LoadingScreen.tscn` by default).  
- `Credits.tscn` reads from `ATTRIBUTION.md` to automatically generate the content for it's scrolling text label.  
- The `UISoundController` node automatically attaches sounds to buttons, tab bars, sliders, and line edits in the scene. `UISoundControllerAutoload.tscn` can be enabled in the project autoloads to apply settings project-wide.
- `InGameMenuController.gd` controls opening and closing a menu and pausing the game in the background.
- The `PauseMenuController` node loads the `PauseMenu.tscn` (using `InGameMenuController.gd`) when triggering `ui-cancel`.
- `GameUI.tscn` is a demo game scene that displays recognized action inputs, and features the `PauseMenuController` node, the `LevelLoader` node to advance through levels, and `InGameMenuController.gd` to show `SuccessScene.tscn` or `FailureScene.tscn`.

## Usage

### Examples

Changes can be made directly to the contents of the `examples/` folder. Alternatively, the folder can be copied or renamed. By default, the project's main scene is `InitAppWithOpening.tscn`, and it links to other scenes in the `examples/` directory. All the scenes and links can be reasonably safely changed to suit the developer's needs.

### Base vs. Extras

`base/` contains the core features of the package. On first use, it's recommended to keep the `extras/` folder. Features can be added and removed as needed.

If a developer wants to start minimally, they may use just the `base/` folder, and safely remove the `extras/` folder by following the [minimal](#minimal) instructions.

Compare [features](#features) to decide which approach is best for your project.

#### Minimal

If you just want to use just the projects minimum `base/` folder:

1.  Go to `Project > Project Settings… > General > Application > Run`.
2.  Update `Main Scene` to `res://addons/maaacks_game_template/base/scenes/InitApp/InitApp.tscn`.
3.  Go to `Project > Project Settings… > Autoload`.
4.  Remove autoloads that start with the path `res://addons/maaacks_game_template/extras/*`.
    1.  `ProjectUiSoundController`
    2.  `ProjectLevelLoader`
    3.  `RuntimeLogger`
5.  Close the window.
6.  Delete the extra folders from the plugin:
    1.  `res://addons/maaacks_game_template/extras/`
    2.  `res://addons/maaacks_game_template/examples/`
7.  If using the template version, delete the extra folders from the project's root directory:
    1.  `res://Media/`
    2.  `res://Examples/`
8.  Reload the project.
    
Lastly, this `README.md` can both be removed or updated to match your project.

The remaining instructions will apply roughly the same.

### New Project
These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

1.  Update the project’s name.
    

    1.  Go to `Project > Project Settings… > General > Application > Config`.
    2.  Update `Name` to `"Game Name"`.
    3.  Close the window.
    4.  Open `MainMenu.tscn`.
    5.  Select the `Title` node.
    6.  Update the `Text` to `"Game Name"`.
    7.  Save the scene.


2.  Point the main menu to the game scene.
    

    1.  Open `MainMenu.tscn`.
    2.  Select the `MainMenu` node.
    3.  Update `Game Scene Path` to the path of “Game Name” game scene.
    4.  Save the scene.


3.  Update the project’s inputs.
    

    1.  Go to `Project > Project Settings… > Input Map`.
    2.  Update the input actions and keybindings for “Game Name”.
    3.  Close the window.
    4.  Open `InputOptionsMenu.tscn` (or `MasterOptionsMenu`, which contains an instance of the scene).
    5.  Select the `Controls` node.
    6.  Update the `Action Name Map` to show readable names for “Game Name” input actions.
    7.  Save the scene.
    

4.  Add sound effects to the UI.


    1.  By scene.


        1.  Open `MainMenu.tscn` and `PauseMenu.tscn`.
        2.  Select the `UISoundController` node.
        3.  Add audio streams to the various UI node events.
        4.  Save the scenes.
   
   
    2.  Project-wide, with `extras/`.


        1.  Go to `Project > Project Settings… > Autoload`.
        2.  Make sure `UISoundControllerAutoload` is listed.
            1.  Note: It does not need a global variable enabled.
        3.  Close the window.        
        4.  Open `UISoundControllerAutoload.tscn`.
        5.  Select the `UISoundController` node.
        6.  Add audio streams to the various UI node events.
        7.  Save the scene.



5.  Update the game credits / attribution and license.
    

    1.  Keep, update, or remove `res://LICENSE.txt`.
    2.  Copy `res://ATTRIBUTION_example.md` over `res://ATTRIBUTION.md`.
    3.  Update `res://ATTRIBUTION.md` with “Game Name” credits, following the example.
    4.  Open `Credits.tscn`.
    5.  Select the `Credits` node.
    6.  Update the `Attribution File Path` to `res://ATTRIBUTION.md`.
    7.  Reload `Credits.tscn` scene to apply changes from `res://ATTRIBUTION.md`.


### Existing Project

For an existing project, developers can copy the contents of the `addons/` folder into their project. This will be the case when installing the application from the *plugin* version in the Godot Asset Library.

  

1.  Update the project’s main scene.
    

    1.  Go to `Project > Project Settings… > General > Application > Run`.
    2.  Update `Main Scene` to `res://addons/maaacks_game_template/base/scenes/InitApp/InitApp.tscn`.
    3.  Close the window.
    

2.  Update the project’s autoloads.
    

    1.  Go to `Project > Project Settings… > Autoload`.
    2.  Add `res://addons/maaacks_game_template/base/scripts/SceneLoader.gd`.
    3.  Optionally add:
        1.  `res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectUISoundController.tscn`
        1.  `res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectLevelLoader.tscn`
        2.  `res://addons/maaacks_game_template/extras/scripts/RuntimeLogger.gd`.
    4.  Close the window.

3.  Update the project’s name.
    

    1.  Open `MainMenu.tscn`.
    2.  Select the `Title` node.
    3.  Update the `Text` to `Game Name`.
    4.  Save the scene.
    

4.  Point the main menu to the game scene.
    

    1.  Open `MainMenu.tscn`.
    2.  Select the `MainMenu` node.
    3.  Update `Game Scene Path` to the path of “Game Name” game scene.
    4.  Save the scene.
    

5.  Update the project’s inputs.
    

    1.  Open `InputOptionsMenu.tscn` (or `MasterOptionsMenu`, which contains an instance of the scene).
    2.  Select the `Controls` node.
    3.  Update the `Action Name Map` to show readable names for “Game Name” input actions.
    4.  Save the scene.


6.  Add sound effects to the UI.


    1.  By scene.


        1.  Open `MainMenu.tscn` and `PauseMenu.tscn`.
        2.  Select the `UISoundController` node.
        3.  Add audio streams to the various UI node events.
        4.  Save the scenes.


    2.  Project-wide, with `extras/`.


        1.  Go to `Project > Project Settings… > Autoload`.
        2.  Make sure `UISoundControllerAutoload` is listed.
            1.  Note: It does not need a global variable enabled.
        3.  Close the window.        
        4.  Open `UISoundControllerAutoload.tscn`.
        5.  Select the `UISoundController` node.
        6.  Add audio streams to the various UI node events.
        7.  Save the scene.
   

7.  Update the game credits / attribution.
    

    1.  Copy `res://addons/maaacks_game_template/ATTRIBUTION_example.md` to your project's root directory as `res://ATTRIBUTION.md`.
    2.  Update `res://ATTRIBUTION.md` with “Game Name” credits, following the example.
    3.  Open `Credits.tscn`.
    4.  Select the `Credits` node.
    5.  Update the `Attribution File Path` to `res://ATTRIBUTION.md`.
    6.  Reload `Credits.tscn` scene to apply changes from `res://ATTRIBUTION.md`.
   

## Links
[Attribution](ATTRIBUTION.md)  
[License](LICENSE.txt)  