# New Projects

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


5.  Update the game credits / attribution.
    

    1. Copy `res://ATTRIBUTION_example.md` over `res://ATTRIBUTION.md`.
    2.  Update `res://ATTRIBUTION.md` with “Game Name” credits, following the example.
    3.  Open `Credits.tscn`.
    4.  Select the `Credits` node.
    5.  Update the `Attribution File Path` to `res://ATTRIBUTION.md`.
    6.  Reload `Credits.tscn` scene to apply changes from `res://ATTRIBUTION.md`.
    7.  Save the scene.

6.  Keep, update, or remove `res://LICENSE.txt`.

7.  If using Git for version control, update `.gitignore` to include `addons/`.
   