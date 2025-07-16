# New Projects

These instructions assume starting with the entire contents of the project folder. This will be the case when cloning the repo, or starting from the *template* version in the Godot Asset Library.
  

1.  Finish setup and remove duplicate example files.


    1.  Go to `Project > Tools > Copy Maaack's Game Template Examples`.
    2.  Click `Cancel` in the first window asking to copy the examples. It's already done.
    3.  Select a theme in the next window if desired.
    4.  Go to `Project > Tools > Delete Maaack's Game Template Examples`.
    5.  Click `Yes` in the first window.


2.  Update the project’s name.


    1.  Go to `Project > Project Settings… > General > Application > Config`.
    2.  Update `Name` to `"Game Name"`.
    3.  Close the window.
    4.  Open `main_menu_with_animations.tscn`.
    5.  Select the `TitleLabel` node.
    6.  The `Text` should match the project's name.
        1. If `Text` is customized, set `Auto Update` to false.  
    7.  Select the `SubtitleLabelNode` node and customize the `Text` as desired.
    8.  Save the scene.


3.  Add background music and sound effects to the UI.


    1.  Verify the `Music` and `SFX` audio busses.

        1.  Open the Audio bus editor.
        2.  Confirm that `Music` and `SFX` audio busses are available.
        3.  If the audio bus doesn't exist, add it and save the project.

    2.  Add background music to the Main Menu.

        1.  Import the music asset into the project.
        2.  Open `main_menu_with_animations.tscn`.
        3.  Select the `BackgroundMusicPlayer` node.
        4.  Assign the music asset to the `stream` property.
        5.  Make sure that the `bus` property is set to `Music`.
        6.  Save the scene.
        7.  Optionally, repeat steps 3-5 for background music nodes in:
            1.  `opening_with_logo.tscn`
            2.  `game_ui.tscn`
            3.  `end_credits.tscn`


    3.  Add sound effects to UI elements.


        1.  By scene.


            1.  Open `main_menu_with_animations.tscn` and `pause_menu.tscn`.
            2.  Select the `UISoundController` node.
            3.  Add audio streams to the various UI node events.
            4.  Save the scenes.  


        2.  Project-wide.


            1.  Open `project_ui_sound_controller.tscn`.
            2.  Select the `UISoundController` node.
            3.  Add audio streams to the various UI node events.
            4.  Save the scene.  


4.  Add readable names for input actions to the controls menu.


    1.  Open `input_options_menu.tscn`.
    2.  In the scene tree, select the `Controls` node.  
    3.  In the node inspector, select the desired input remapping mode (defaults to `List`).  
    4.  In the scene tree, select `InputActionsList` or `InputActionsTree`, depending on the choice of input remapping. The other node should be hidden.  
    5.  In the node inspector, update the `Input Action Names` and corresponding `Readable Action Names` to show user-friendly names for the project's input actions.  
    6.  Save the scene.  


5.  Add / remove configurable settings to / from menus.


    1.  Open `mini_options_menu.tscn` or `[audio|visual|input|game]_options_menu.tscn` scenes to edit their options.
    2.  If an option is not desired, it can always be hidden, or removed entirely (sometimes with some additional work).
    3.  If a new option is desired, refer to [Adding Custom Options.](/addons/maaacks_game_template/docs/AddingCustomOptions.md)


6.  Update the game credits / attribution.


    1.  Update the example `ATTRIBUTION.md` with the project's credits.
    2.  Open `scrollable_credits.tscn` and  `scrolling_credits.tscn`.
    3.  Check the `CreditsLabel` has updated with the text.
    4.  Optionally, change settings or disable `Auto Update`.
    5.  Save both scenes (even they show no changes).


7.  Keep, update, or remove `res://LICENSE.txt`.  


8.  Optionally, if using Git for version control, update `.gitignore` to include `addons/`.  


9.  Continue with:

    1.  [Setting up the Main Menu.](/addons/maaacks_game_template/docs/MainMenuSetup.md)  
    2.  [Setting up a Game Scene.](/addons/maaacks_game_template/docs/GameSceneSetup.md)  
    3.  [Loading scenes asynchronously.](/addons/maaacks_game_template/docs/LoadingScenes.md)  
    4.  [Adding icons to the Input Options.](/addons/maaacks_game_template/docs/InputIconMapping.md)  
    5.  [Adding Custom Options.](/addons/maaacks_game_template/docs/AddingCustomOptions.md)
    6.  [Utilizing Game Saving.](/addons/maaacks_game_template/docs/GameSaving.md)  
