# Godot Game Template
For Godot 4.2

This template has a main menu, pause menu, and credits scene. It supports basic accessibility features like input rebinding, sound, and video controls.

[Example on itch.io](https://maaack.itch.io/godot-game-template)

![Main Menu](/Media/Screenshot-3-1.png)  
![Key Rebinding](/Media/Screenshot-3-2.png)  
![Audio Controls](/Media/Screenshot-3-4.png)  
![Pause Menu](/Media/Screenshot-3-6.png)  

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
- `ProjectMusicController.tscn` is an autoload scene that keeps music playing between scenes. It detects music stream players as they are added to the scene tree, reparents them to itself, and blends the tracks.  
- The `UISoundController` node automatically attaches sounds to buttons, tab bars, sliders, and line edits in the scene. `ProjectUISoundController.tscn` can used to apply UI sound effects project-wide.
- `InGameMenuController.gd` controls opening and closing a menu and pausing the game in the background.
- The `PauseMenuController` node loads the `PauseMenu.tscn` (using `InGameMenuController.gd`) when triggering `ui-cancel`.
- `GameUI.tscn` is a demo game scene that displays recognized action inputs, and features the `PauseMenuController` node, the `LevelLoader` node to advance through levels, and `InGameMenuController.gd` to show `SuccessScene.tscn` or `FailureScene.tscn`.

## Usage

Set your project's main scene to `InitApp.tscn`, `InitAppWithOpening.tscn`, or any scene that inherits from those. Then run the project.

### Examples

Changes can be made directly to the contents of the `examples/` folder. Alternatively, the folder can be copied or renamed. 

Most scenes that a developer would commonly change are in the `examples/` directory, and all the scenes and links can be changed to suit the developer's needs. Scenes in `examples/` link to others within the same directory, though they often inherit from either `base/` or `extras/`. 

In the template version, the project's main scene starts as `InitAppWithOpening.tscn` in `res://Examples/`. 

### Base vs. Extras

`base/` contains the core features of the package. Main menu, options menus, and credits. It has no other dependencies.

`extras/` contains features that supplement or extend the core features. Some are dependent on `base/`, while others are stand-alone. Many of the scripts and scenes are used in the `examples/` scenes. 

See the [features](#features) section for more details.

#### Minimal

Advanced users that just want to use the project's minimum `base/` contents can safely remove `extras/` by following the [Minimal Install Instructions](/addons/maaacks_game_template/docs/MinimalInstall.md).  

The remaining instructions will apply roughly the same.

### New Project
These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

[New Project Instructions](/addons/maaacks_game_template/docs/NewProject.md)

### Existing Project

For an existing project, developers can copy the contents of the `addons/` folder into their project. This will be the case when installing the application from the *plugin* version in the Godot Asset Library.

[Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md)  
   

## Links
[Attribution](ATTRIBUTION.md)  
[License](LICENSE.txt)  