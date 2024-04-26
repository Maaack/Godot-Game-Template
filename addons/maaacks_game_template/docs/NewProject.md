# New Projects

These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

1.  Update the project’s name.
    

    1.  Go to `Project > Project Settings… > General > Application > Config`.
    2.  Update `Name` to `"Game Name"`.
    3.  Close the window.
    4.  Open `MainMenu.tscn`.
    5.  Select the `Title` node.
    6.  Update the `Text` to your project's title.
    7.  Select the `Subtitle` node.
    8.  Update the `Text` to a desired subtitle or empty.
    9.  Save the scene.
    

2.  Link the main menu to the game scene.
    

    1.  Open `MainMenu.tscn`.
    2.  Select the `MainMenu` node.
    3.  Update `Game Scene Path` to the path of the project's game scene.
    4.  Save the scene.
    

3.  Add background music and sound effects to the UI.

    1.  Verify the `Music` and `SFX` audio busses.

        1.  Open the Audio bus editor.
        2.  Make sure there is a bus for `Music` and another for `SFX`.
        3.  Add the busses if they do not exist.

    2.  Add background music to the Main Menu.

        1.  Import the music asset into the project.
        2.  Open `MainMenu.tscn`.
        3.  Select the `BackgroundMusicPlayer` node.
        4.  Assign the music asset to the `stream` property.
        5.  Save the scene.
        6.  Optionally, repeat steps 3-5 for background music nodes in:
            1.  `Opening.tscn`
            2.  `GameUI.tscn`
            3.  `EndCredits.tscn`


    3.  Add sound effects to UI elements.


        1.  By scene.


            1.  Open `MainMenu.tscn` and `PauseMenu.tscn`.
            2.  Select the `UISoundController` node.
            3.  Add audio streams to the various UI node events.
            4.  Save the scenes.


        2.  Project-wide.


            1.  Open `ProjectUISoundController.tscn`.
            2.  Select the `UISoundController` node.
            3.  Add audio streams to the various UI node events.
            4.  Save the scene.
   

4.  Add readable names for input actions to the controls menu.
    

    1.  Open `InputOptionsMenu.tscn` (or `MasterOptionsMenu`, which contains an instance of the scene).
    2.  Select the `Controls` node.
    3.  Update the `Action Name Map` to show readable names for the project's input actions.  
        1.  The keys are the project's input action names, while the values are the names shown in the controls menu.  
        2.  An example is provided. It can be updated or removed, either in the inspector for the node, or in the code of `InputOptionsMenu.gd`.  
    4.  Save the scene.  


5.  Update the game credits / attribution.
    

    1.  Copy `res://addons/maaacks_game_template/ATTRIBUTION_example.md` to your project's root directory as `res://ATTRIBUTION.md`.
    2.  Update `res://ATTRIBUTION.md` with the project's credits, following the example.
    3.  Open `Credits.tscn`.
    4.  Select the `Credits` node.
    5.  Update the `Attribution File Path` to `res://ATTRIBUTION.md`.
    6.  Reload the `Credits.tscn` scene to update the contents.
    7.  Save the scene.

6.  Keep, update, or remove `res://LICENSE.txt`.

7.  Optionally, if using Git for version control, update `.gitignore` to include `addons/`.
   