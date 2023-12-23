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

### App (Base)

The `App/` folder holds the core components of the menus application.

-   Main Menu    
-   Options Menus
-   Pause Menu
-   Credits
-   Loading Screen
-   Persistent Settings
-   Simple Config Interface
-   Keyboard/Mouse Support
-   Gamepad Support
-   Centralized UI Sound Control

### Extras

The `Extras/` folder holds components that extend the core application.

-   Example Game Scene
-   Opening Scene
-   Success & Failure Scenes
-   End Credits
-   Level Advancement
-   Logging Scripts
-   Additional Inherited Scenes from `App/`:
    -   `OptionsMenu.tscn`
    -   `MasterOptionsMenu.tscn`
    -   `MainMenu.tscn` 
    -   `PauseMenu.tscn`
    -   `InitApp.tscn`

  
### How it Works
- `InitApp.tscn` is the project's main scene. It loads all the configuration settings from the config file (if it exists) into game. It then loads the next scene (`Opening.tscn` or `MainMenu.tscn`).  
- `Opening.tscn` is a simple scene for fading in/out a few images at the start of the game. It then loads the next scene (`MainMenu.tscn`).  
- `MainMenu.tscn` is where a player can start the game, change settings, watch credits, or quit. It can link to the path of a game scene to play, and the packed scene of an options menu to use.  
- `SceneLoader.tscn` loads scenes with `LoadingScreen.tscn` in cases where a progress bar is desired. It is set as an autoload.  
- `Credits.tscn` reads from `ATTRIBUTION.md` to automatically generate the content for it's scrolling text label.  
- The `UISoundController` node automatically attaches sounds to buttons, tab bars, sliders, and line edits in the scene. `UISoundControllerAutoload.tscn` can be enabled in the project autoloads to apply settings project-wide.
- `InGameMenuController.gd` controls opening and closing a menu and pausing the game in the background.
- The `PauseMenuController` node loads the `PauseMenu.tscn` (using `InGameMenuController.gd`) when triggering `ui-cancel`.
- `GameUI.tscn` is a demo game scene that displays recognized action inputs, and features the `PauseMenuController` node, the `LevelLoader` node to advance through levels, and `InGameMenuController.gd` to show `SuccessScene.tscn` or `FailureScene.tscn`.

## Usage

### App vs. Extras

`App/` contains the core features of the package. On first use, it's recommended to keep the `Extras/` folder, and make changes there. Features can be added and removed as needed.

To start minimally, use just the `App/` folder, and safely remove the `Extras/` folder by following the [minimal](#minimal) instructions.

Compare [features](#features) to decide which approach is best for your project.

#### Minimal

If you just want to use just the projects minimum `App/` folder:

1.  Go to `Project > Project Settings… > General > Application > Run`.
2.  Update `Main Scene` to `res://App/Scenes/InitApp/InitApp.tscn`.
3.  Go to `Project > Project Settings… > Autoload`.
4.  Remove autoloads that start with the path `res://Extras/...`.
    1.  `ProjectUiSoundController`
    2.  `ProjectLevelLoader`
    3.  `RuntimeLogger`
5.  Close the window.
6.  Delete the `Extras/` folder.
7.  Reload the project.
    

The remaining instructions will apply the same for either folder you decide to use.

#### Extra Minimal

The pause menu feature can be removed if not used. From the `App/` folder, delete `PauseMenu/*`, `PauseMenuController.gd`, and `InGameMenuController.gd`.

Lastly, this `README.md` and the `Media/` directory can both be removed.

### New Project
These instructions assume starting with the entire contents of the project folder.
  

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
    4.  Open `InputOptionsMenu.tscn`.
    5.  Select the `Controls` node.
    6.  Update the `Action Name Map` to show readable names for “Game Name” input actions.
    7.  Update the `Add Button Texture` and `Remove Button Texture` with textures.
    8.  Save the scene.
    

4.  Add sound effects to the UI.


    1.  By scene.


        1.  Open `MainMenu.tscn` and `PauseMenu.tscn`.
        2.  Select the `UISoundController` node.
        3.  Add audio streams to the various UI node events.
        4.  Save the scenes.
   
   
    2.  Project-wide, with `Extras/`.


        1.  Open `UISoundControllerAutoload.tscn`.
        2.  Select the `UISoundController` node.
        3.  Add audio streams to the various UI node events.
        4.  Save the scene.
        5.  Go to `Project > Project Settings… > Autoload`.
        6.  Enable `UISoundControllerAutoload`.
        7.  Close the window.


5.  Update the game credits / attribution.
    

    1.  Copy `ATTRIBUTION_example.md` over `ATTRIBUTION.md`.
    2.  Update `ATTRIBUTION.md` with “Game Name” credits, following the example.
    3.  Reload `Credits.tscn` scene to apply changes from `ATTRIBUTION.md`.
    4.  Include the attribution in exports.


        1.  Go to Project > Export.
        2.  Select one of “Game Name” presets (or set them up).
        3.  Select the Resources tab.
        4.  Update `Filters to export non-resource file/folders` to include `ATTRIBUTION.md`.
        5.  Close the window.
    


### Existing Project

For an existing project, just copy over the `App/` folder (optionally the `Extras/` folder, as well).

  

1.  Update the project’s main scene.
    

    1.  Go to `Project > Project Settings… > General > Application > Run`.
    2.  Update `Main Scene` to `res://…/InitApp.tscn`.
    3.  Close the window.
    

2.  Update the project’s autoloads.
    

    1.  Go to `Project > Project Settings… > Autoload`.
    2.  Add `res://App/Scripts/SceneLoader.gd`.
    3.  Optionally enable `res://Extras/Scripts/RuntimeLogger.gd`.
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
    

    1.  Open `InputOptionsMenu.tscn`.
    2.  Select the `Controls` node.
    3.  Update the `Action Name Map` to show readable names for “Game Name” input actions.
    4.  Update the `Add Button Texture` and `Remove Button Texture` with textures.
    5.  Save the scene.


6.  Add sound effects to the UI.


    1.  By scene.


        1.  Open `MainMenu.tscn` and `PauseMenu.tscn`.
        2.  Select the `UISoundController` node.
        3.  Add audio streams to the various UI node events.
        4.  Save the scenes.


    2.  Project-wide, with `Extras/`.


        1.  Open `UISoundControllerAutoload.tscn`.
        2.  Select the `UISoundController` node.
        3.  Add audio streams to the various UI node events.
        4.  Save the scene.
        5.  Go to `Project > Project Settings… > Autoload`.
        6.  Enable `UISoundControllerAutoload`.
        7.  Close the window.
   

7.  Update the game credits / attribution.
    

    1.  Copy `ATTRIBUTION_example.md` over `ATTRIBUTION.md`.
    2.  Update `ATTRIBUTION.md` with “Game Name” credits, following the example.
    3.  Reload `Credits.tscn` scene to apply changes from `ATTRIBUTION.md`.
    4.  Include the attribution in exports.


        1.  Go to Project > Export.
        2.  Select one of “Game Name” presets (or set them up).
        3.  Select the Resources tab.
        4.  Update `Filters to export non-resource file/folders` to include `ATTRIBUTION.md`.
        5.  Close the window.
   

## Links
[Attribution](ATTRIBUTION.md)  
[License](LICENSE.txt)  