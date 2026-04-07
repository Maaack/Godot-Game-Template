# Godot Game Template
For Godot 4.6 (4.3+ compatible)

> [!NOTE]  
> Using the latest version of Godot is recommended.   
> See [Main Menu Setup](/addons/maaacks_game_template/docs/MainMenuSetup.md) for use with versions < 4.6.  

This template has a main menu, options menus, pause menu, credits, scene loader, extra tools, and an example game scene.  

[Example on itch.io](https://maaack.itch.io/godot-game-template)  

[Featured Games](#featured-games)  

### Videos

[![Quick Intro Video](https://img.youtube.com/vi/U9CB3vKINVw/hqdefault.jpg)](https://youtu.be/U9CB3vKINVw)  
[More Videos](/addons/maaacks_game_template/docs/Videos.md)

### Screenshots
![Main Menu](/addons/maaacks_game_template/media/screenshot-6-main-menu-5.png)  
![Key Rebinding](/addons/maaacks_game_template/media/screenshot-6-input-list-8.png)  
![Audio Controls](/addons/maaacks_game_template/media/screenshot-6-audio-options-2.png)  
![Video Controls](/addons/maaacks_game_template/media/screenshot-6-video-options-5.png)  
![Pause Menu](/addons/maaacks_game_template/media/screenshot-6-pause-menu-3.png)  
[More Screenshots](/addons/maaacks_game_template/docs/Screenshots.md)  

## Objective

Setup menus and accessibility features in about 15 minutes.

The template can be the start of a new project, or plug into an existing one. It is game agnostic (2D or 3D) and can work with multiple target resolutions, up to 4k and down to 640x360. It's meant to cover the needs for a typical game jam, while remaining scalable and extensible enough to support commercial games.

## Features

### Base

The `base/` folder holds the core components of the menus application.

-   Main Menu    
-   Options Menus
-   Pause Menu
-   Credits
-   Loading Screen
-   Opening Scene
-   Persistent Settings
-   Simple Config Interface
-   Extensible Overlay Menus
-   Keyboard/Mouse Support
-   Gamepad Support
-   UI Sound Controller
-   Background Music Controller
-   Credits Reader (Markdown File Parser)
-   Global State Management (Basic Saving/Loading)
-   Global Config Autoload

### Extras

The `extras/` folder holds components that extend the core application.

-   Level Loaders
-   Level Progress Manager
-   Win / Lose Manager
-   Script for Releasing on [itch.io](https://itch.io/) with [butler](https://itch.io/docs/butler/)
 
### Examples 

The `examples/` folder contains an example project using inherited scenes from the `base/` and `extras/`.

-   Game Scene
-   Level Class & 3 Levels
-   Tutorial Windows & 3 Tutorial Messages
-   Win & Lose Windows
-   Master Options Menu
-   End Credits
-   Main Menu w/ Animations
-   Opening w/ Godot Logo
-   Game and Level State Management

### Minimal

Users that want a minimal set of features can try [Maaack's Minimal Game Template](https://github.com/Maaack/Godot-Minimal-Game-Template) or other options from the [plugin suite](/addons/maaacks_game_template/docs/PluginSuite.md).  


## Installation

### Godot Asset Library
This package is available as both a template and a plugin, meaning it can be used to start a new project, or added to an existing project. 

![Package Icon](/addons/maaacks_game_template/media/game-icon-black-transparent-256x256.png)  

When starting a new project:

1.  Go to the `Asset Library Projects` tab.
2.  Search for "Maaack's Game Template".
3.  Click on the result to open the template details.
4.  Click to Download.
5.  Give the project a new name and destination.
6.  Click to Install & Edit.
7.  Continue with the [Basic Setup](/addons/maaacks_game_template/docs/BasicSetup.md)

When editing an existing project:

1.  Go to the `AssetLib` tab.
2.  Search for "Maaack's Game Template Plugin".
3.  Click on the result to open the plugin details.
4.  Click to Download.
5.  Check that contents are getting installed to `addons/` and there are no conflicts.
6.  Click to Install.
7.  Reload the project (you may see errors before you do this).
8.  Enable the plugin from the Project Settings > Plugins tab.  
    1.  If it's enabled for the first time, the setup wizard will start.  
    2.  Close the window behind it and complete the setup wizard.  
9.  Continue with the [Basic Setup](/addons/maaacks_game_template/docs/BasicSetup.md)


### GitHub


1.  Download the latest release version from [GitHub](https://github.com/Maaack/Godot-Game-Template/releases/latest).  
2.  Extract the contents of the archive.
3.  Move the `addons/maaacks_game_template` folder into your project's `addons/` folder.  
4.  Open/Reload the project.  
5.  Enable the plugin from the Project Settings > Plugins tab.  
    1.  If it's enabled for the first time, the setup wizard will start.  
    2.  Close the window behind it and complete the setup wizard.  
6.  Continue with the [Basic Setup](/addons/maaacks_game_template/docs/BasicSetup.md)


## Usage

[Basic Setup](/addons/maaacks_game_template/docs/BasicSetup.md) is done through the _Setup Wizard_ at `Project > Tools > Run Maaack's Game Template Setup...`.

As part of setup, example scenes are copied out of `/addons/` into a desired folder (project root by default). These can be edited to fit requirements.
   
### More Documentation

[Main Menu Setup](/addons/maaacks_game_template/docs/MainMenuSetup.md)  
[Options Menu Setup](/addons/maaacks_game_template/docs/OptionsMenuSetup.md)  
[Game Scene Setup](/addons/maaacks_game_template/docs/GameSceneSetup.md)  
[Updating Credits](/addons/maaacks_game_template/docs/UpdatingCredits.md)  
[Blending Music](/addons/maaacks_game_template/docs/BlendingMusic.md)  
[Adding UI Sound Effects](/addons/maaacks_game_template/docs/AddingUISFX.md)  
[Loading Scenes](/addons/maaacks_game_template/docs/LoadingScenes.md)  
[Input Icon Mapping](/addons/maaacks_game_template/docs/InputIconMapping.md)  
[Joypad Inputs](/addons/maaacks_game_template/docs/JoypadInputs.md)  
[Game Saving](/addons/maaacks_game_template/docs/GameSaving.md)  
[How Parts Work](/addons/maaacks_game_template/docs/HowPartsWork.md)  
[Moving Files](/addons/maaacks_game_template/docs/MovingFiles.md)  
[Uploading to itch.io](/addons/maaacks_game_template/docs/UploadingToItchIo.md)  
[Build and Publish Your Game Using CICD](/addons/maaacks_game_template/docs/BuildAndPublish.md)  
[Automatic Updating](/addons/maaacks_game_template/docs/AutomaticUpdating.md)  
[Exhibiting Your Game](/addons/maaacks_game_template/docs/Exhibiting.md)  

---

## Featured Games

| HeartFix Express | Baking Godium | Rent Seek Kill |  
| :-------:| :-------: | :-------: |
| ![HeartFix Express](/addons/maaacks_game_template/media/thumbnail-game-heartfix-express.png) | ![Baking Godium](/addons/maaacks_game_template/media/thumbnail-game-baking-godium.png) | ![Rent-Seek-Kill](/addons/maaacks_game_template/media/thumbnail-game-rent-seek-kill.png) |
|  [Find on Steam](https://store.steampowered.com/app/3983290/HeartFix_Express_Demo/)  | [Play on itch.io](https://maaack.itch.io/baking-godium) | [Play on itch.io](https://xandruher.itch.io/rent-seek-kill)  |


[All Shared Games](/addons/maaacks_game_template/docs/GamesMade.md)  


## Community

Join the [Discord server](https://discord.gg/AyZrJh5AMp ) and share your work with others. It's also a space for getting or giving feedback, and asking for help. 
 

## Links
[Attribution](/addons/maaacks_game_template/ATTRIBUTION.md)  
[License](/addons/maaacks_game_template/LICENSE.txt)  
[Godot Asset Library - Template](https://godotengine.org/asset-library/asset/2703)  
[Godot Asset Library - Plugin](https://godotengine.org/asset-library/asset/2709)  
