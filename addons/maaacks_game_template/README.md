# Godot Game Template
For Godot 4.4 (4.3+ compatible)

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

### Extras

The `extras/` folder holds components that extend the core application.

-   Win & Lose Menus
-   Level Loaders
-   Level Progress Manager
-   Logging Scripts
-   Script for Releasing on [itch.io](https://itch.io/) with [butler](https://itch.io/docs/butler/)
 
### Examples 

The `examples/` folder contains an example project using inherited scenes from the `base/` and `extras/`.

-   Example Game Scene
-   Base Level Class
-   Example Levels
-   End Credits
-   Additional Inherited Scenes:
    -   Game Options Menu w/ Reset button
    -   Master Options Menu w/ Game Options tab 
    -   Main Menu w/ Animations
    -   Opening w/ Godot Logo
    -   Level Loading Screen
    -   Loading Screen w/ Shader Pre-caching 

### Minimal

Users that want a minimal set of features can try [Maaack's Menus Template](https://github.com/Maaack/Godot-Menus-Template) or other options from the [plugin suite](/addons/maaacks_game_template/docs/PluginSuite.md).  


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


## Usage

### New Project
These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

[New Project Instructions](/addons/maaacks_game_template/docs/NewProject.md)

### Existing Project

These instructions assume starting with just the contents of `addons/`. This will be the case when installing the *plugin* version in the Godot Asset Library.

[Existing Project Instructions](/addons/maaacks_game_template/docs/ExistingProject.md)  
   
### More Documentation

[Main Menu Setup](/addons/maaacks_game_template/docs/MainMenuSetup.md)  
[Game Scene Setup](/addons/maaacks_game_template/docs/GameSceneSetup.md)  
[Loading Scenes](/addons/maaacks_game_template/docs/LoadingScenes.md)  
[Input Icon Mapping](/addons/maaacks_game_template/docs/InputIconMapping.md)  
[Joypad Inputs](/addons/maaacks_game_template/docs/JoypadInputs.md)  
[Add Custom Options](/addons/maaacks_game_template/docs/AddingCustomOptions.md)  
[Game Saving](/addons/maaacks_game_template/docs/GameSaving.md)  
[How Parts Work](/addons/maaacks_game_template/docs/HowPartsWork.md)  
[Uploading to itch.io](/addons/maaacks_game_template/docs/UploadingToItchIo.md)  
[Automatic Updating](/addons/maaacks_game_template/docs/AutomaticUpdating.md)  

---

## Featured Games

| Spud Customs | Rent Seek Kill  | A Darkness Like Gravity  |  
| :-------:| :-------: | :-------: |
![Spud Customs](/addons/maaacks_game_template/media/thumbnail-game-spud-customs.png)  |  ![Rent-Seek-Kill](/addons/maaacks_game_template/media/thumbnail-game-rent-seek-kill.png)  |  ![A Darkness Like Gravity](/addons/maaacks_game_template/media/thumbnail-game-a-darkness-like-gravity.png)  |
[Find on Steam](https://store.steampowered.com/app/3291880/Spud_Customs/) | [Play on itch.io](https://xandruher.itch.io/rent-seek-kill)  |  [Play on itch.io](https://maaack.itch.io/a-darkness-like-gravity)  |


[All Shared Games](/addons/maaacks_game_template/docs/GamesMade.md)  


## Community

Join the [Discord server](https://discord.gg/AyZrJh5AMp ) and share your work with others. It's also a space for getting or giving feedback, and asking for help. 
 

## Links
[Attribution](/addons/maaacks_game_template/ATTRIBUTION.md)  
[License](/addons/maaacks_game_template/LICENSE.txt)  
[Godot Asset Library - Template](https://godotengine.org/asset-library/asset/2703)  
[Godot Asset Library - Plugin](https://godotengine.org/asset-library/asset/2709)  
