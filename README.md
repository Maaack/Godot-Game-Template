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
-   Centrallized Music Control
-   Additional Autoloaded Classes
-   Scripts for Testing & Releasing
 
### Examples 

The `examples/` folder contains an example project using inherited scenes from the `base/` and `extras/`.

-   Example Game Scene
-   Level Advancement
-   End Credits
-   Additional Inherited Scenes:
    -   Game Options Menu w/ Reset button
    -   Master Options Menu w/ Game Options tab 
    -   Main Menu w/ Animations
    -   Pause Menu w/ Linked Scenes
    -   Init App w/ Opening Scene
    -   Loading Screen w/ Shader Pre-caching 

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

## Installation

### Godot Asset Library
This package is available as both a template and a plugin, meaning it can be used to start a new project, or added to an existing project. 

When starting a new project:

1.  Go to the `Asset Library Projects` tab.
2.  Search for "Maaack's Game Template".
3.  Click on the result to open the template details.
4.  Click to Download.
5.  Give the project a new name and destination.
6.  Click to Install & Edit.
7.  Continue with the [New Project Instructions](/addons/maaacks_game_template/docs/NewProject.md)

When editing an existing project:

1.  Go to the `AssetLib` tab.
2.  Search for "Maaack's Game Template Plugin".
3.  Click on the result to open the plugin details.
4.  Click to Download.
5.  Check that contents are getting installed to `addons/` and there are no conflicts.
6.  Click to Install.
7.  Reload the project (you may see errors before you do this).
8.  Enable the plugin from the Project Settings > Plugins tab.
9.  Continue with the [Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md)  


### GitHub


1.  Download the latest release version from [GitHub](https://github.com/Maaack/Godot-Game-Template/releases/latest).  
2.  Extract the contents of the archive.
3.  Move the `addons/maaacks_game_template` folder into your project's `addons/` folder.  
4.  Open/Reload the project.  
5.  Enable the plugin from the Project Settings > Plugins tab.  
6.  Continue with the [Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md) 

#### Minimal

Advanced users that just want to use the project's minimum `base/` contents can safely remove `extras/` by following the [Minimal Install Instructions](/addons/maaacks_game_template/docs/MinimalInstall.md).  

## Usage

### Main Scene

Set your project's main scene to `InitApp.tscn`, `InitAppWithOpening.tscn`, or any scene that inherits from those.

In the template version, the project's main scene starts as `InitAppWithOpening.tscn` in `res://Examples/`. 

### Examples

Changes can be made directly to the contents of the `examples/` folder. Alternatively, the folder can be copied or renamed. 

Most scenes that a developer would commonly change are in the `examples/` directory, and all the scenes and links can be changed to suit the developer's needs. Scenes in `examples/` link to others within the same directory, though they often inherit from either `base/` or `extras/`. 

### New Project
These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

[New Project Instructions](/addons/maaacks_game_template/docs/NewProject.md)

### Existing Project

For an existing project, developers can copy the contents of the `addons/` folder into their project. This will also be the case when installing the application from the *plugin* version in the Godot Asset Library.

[Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md)  
   


## Links
[Attribution](ATTRIBUTION.md)  
[License](LICENSE.txt)  
[Godot Asset Library - Template](https://godotengine.org/asset-library/asset/2703)  
[Godot Asset Library - Plugin](https://godotengine.org/asset-library/asset/2709)  
