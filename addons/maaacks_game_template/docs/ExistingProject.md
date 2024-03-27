# Existing Project

For an existing project, developers can copy the contents of the `addons/` folder into their project. This will be the case when installing the application from the *plugin* version in the Godot Asset Library.

  

1.  Update the project’s main scene.
    

    1.  Go to `Project > Project Settings… > General > Application > Run`.
    2.  Update `Main Scene` to `res://addons/maaacks_game_template/examples/scenes/InitApp/InitAppWithOpening.tscn`.
        1.  Alternatively, use `res://addons/maaacks_game_template/base/scenes/InitApp/InitApp.tscn` for a minimal use-case.
        2.  The developer can also create their own scene inheriting from `InitApp.tscn` and set it as the main scene.
    3.  Close the window.
    

2.  Update the project’s autoloads.
    

    1.  Go to `Project > Project Settings… > Autoload`.
    2.  Add `res://addons/maaacks_game_template/base/scripts/SceneLoader.gd`.
    3.  Optionally add:
        1.  `res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectUISoundController.tscn`
        1.  `res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectLevelLoader.tscn`
        2.  `res://addons/maaacks_game_template/extras/scripts/RuntimeLogger.gd`.
    4.  Close the window.

3.  Update the project’s name in the main menu.
    

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
    7.  Save the scene.
   