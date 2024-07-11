# Godot Game Template
For Godot 4.2

This template has a main menu, options menus, pause menu, credits, scene loader, extra tools, and an example game scene.

[Example on itch.io](https://maaack.itch.io/godot-game-template)

#### Videos

[![Quick Intro Video](https://img.youtube.com/vi/U9CB3vKINVw/hqdefault.jpg)](https://youtu.be/U9CB3vKINVw)  
[![Installation Video](https://img.youtube.com/vi/-QWJnZ8bVdk/hqdefault.jpg)](https://youtu.be/-QWJnZ8bVdk)  
[All videos](/addons/maaacks_game_template/docs/Videos.md)

#### Screenshots
![Main Menu](/addons/maaacks_game_template/media/Screenshot-3-1.png)  
![Key Rebinding](/addons/maaacks_game_template/media/Screenshot-3-2.png)  
![Audio Controls](/addons/maaacks_game_template/media/Screenshot-3-4.png)  
![Pause Menu](/addons/maaacks_game_template/media/Screenshot-3-6.png)  
[All screenshots](/addons/maaacks_game_template/docs/Screenshots.md)

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
-   UI Sound Controller
-   Background Music Controller

### Extras

The `extras/` folder holds components that extend the core application.

-   Pause Menu
-   Opening Scene
-   Win & Lose Scenes
-   Logging Scripts
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
    -   Loading Screen w/ Shader Pre-caching 

### How it Works
- `AppConfig.tscn` is set as the first autoload. It calls `AppSettings.gd` to load all the configuration settings from the config file (if it exists) through `Config.gd`.
- `SceneLoader.tscn` is set as the second autoload.  It can load scenes in the background or with a loading screen (`LoadingScreen.tscn` by default).   
- `Opening.tscn` is a simple scene for fading in/out a few images at the start of the game. It then loads the next scene (`MainMenu.tscn`).  
- `MainMenu.tscn` is where a player can start the game, change settings, watch credits, or quit. It can link to the path of a game scene to play, and the packed scene of an options menu to use.  
- `OptionControl.tscn` and its inherited scenes are used for most configurable options in the menus. They work with `Config.gd` to keep settings persistent between runs.
- `Credits.tscn` reads from `ATTRIBUTION.md` to automatically generate the content for it's scrolling text label.  
- The `UISoundController` node automatically attaches sounds to buttons, tab bars, sliders, and line edits in the scene. `ProjectUISoundController.tscn` is an autload used to apply UI sounds project-wide.
- `ProjectMusicController.tscn` is an autoload that keeps music playing between scenes. It detects music stream players as they are added to the scene tree, reparents them to itself, and blends the tracks.  
- `InGameMenuController.gd` controls opening and closing a menu and pausing the game in the background.
- The `PauseMenuController` node loads the `PauseMenu.tscn` (using `InGameMenuController.gd`) when triggering `ui-cancel`.
- `GameUI.tscn` is a demo game scene that displays recognized action inputs, and features the `PauseMenuController` node, the `LevelLoader` node to advance through levels, and `InGameMenuController.gd` to show `WinScreen.tscn` or `LoseScreen.tscn`.
  
## Installation

### Godot Asset Library
This package is available as both a template and a plugin, meaning it can be used to start a new project, or added to an existing project. 

![Package Icon](/addons/maaacks_game_template/media/Game-Icon-black-transparent-256x256.png)  

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
    If it's enabled for the first time,
    1.  A dialogue window will appear asking to copy the example scenes out of `addons/`.
    2.  Another dialogue window will ask to update the project's main scene.
9.  Continue with the [Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md)  


### GitHub


1.  Download the latest release version from [GitHub](https://github.com/Maaack/Godot-Game-Template/releases/latest).  
2.  Extract the contents of the archive.
3.  Move the `addons/maaacks_game_template` folder into your project's `addons/` folder.  
4.  Open/Reload the project.  
5.  Enable the plugin from the Project Settings > Plugins tab.  
    If it's enabled for the first time,
    1.  A dialogue window will appear asking to copy the example scenes out of `addons/`.
    2.  Another dialogue window will ask to update the project's main scene.
6.  Continue with the [Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md) 

#### Minimal

Users that want a minimal set of features can try [Maaack's Menus Template](https://github.com/Maaack/Godot-Menus-Template).  

## Usage

Changes can be made directly to scenes and scripts outside of `addons/`. 

A copy of the `examples/` directory is made outside of `addons/` when the plugin is enabled for the first time. However, if this is skipped, it is recommended developers inherit from scenes they want to use, and save the inherited scene outside of `addons/`. This avoids changes getting lost either from the package updating, or because of a `.gitignore`.

### New Project
These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

[New Project Instructions](/addons/maaacks_game_template/docs/NewProject.md)

### Existing Project

These instructions assume starting with just the contents of `addons/`. This will be the case when installing the *plugin* version in the Godot Asset Library.

[Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md)  
   


## Links
[Attribution](/addons/maaacks_game_template/ATTRIBUTION.md)  
[License](/addons/maaacks_game_template/LICENSE.txt)  
[Godot Asset Library - Template](https://godotengine.org/asset-library/asset/2703)  
[Godot Asset Library - Plugin](https://godotengine.org/asset-library/asset/2709)  
