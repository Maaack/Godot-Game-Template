# Existing Project

These instructions assume starting with just the contents of `addons/` and going through the installer to copy the examples content into your project. This will be the case when installing the *plugin* version in the Godot Asset Library.

To revisit any part of the initial setup, find the `Setup Wizard` at `Project > Tools > Run Maaack's Game Template Setup...`. Example files can be re-copied from the `Setup Wizard`, assuming they have not been deleted.

1.  Update the project’s name in the main menu.
    

    1.  Open `main_menu_with_animations.tscn`.
    2.  Select the `TitleLabel` node.
    3.  The `Text` should match the project's name (in the project's settings).
        1. If `Text` is customized, set `Auto Update` to false.
    4.  Select the `SubtitleLabelNode` node and customize the `Text` as desired.
    5.  Save the scene.
    

2.  Link the main menu to a custom game scene (skip if using the example game scene).
    

    1.  Open `main_menu_with_animations.tscn`.
    2.  Select the `MainMenu` node.
    3.  Update `Game Scene Path` to the path of the project's game scene.
    4.  Save the scene.
    

3.  Add background music and sound effects to the UI.

    1.  Verify the `Music` and `SFX` audio busses.

        1.  Open the Audio bus editor.
        2.  Confirm that `Music` and `SFX` audio busses are available.
            1.  If the last bus is `New Bus`, try restarting the editor and checking again.
        3.  If the audio bus doesn't exist, add it and save the project.

    2.  Add background music to the Main Menu.

        1.  Import the music asset into the project.
        2.  Open `main_menu_with_animations.tscn`.
        3.  Select the `BackgroundMusicPlayer` node.
        4.  Assign the music asset to the `stream` property.
        5.  Make sure that the `bus` property is set to `Music`.
        6.  Save the scene.
        7.  Optionally, repeat steps 3-5 for background music nodes in:
            1.  `opening.tscn`
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
    2.  Open `credits_label.tscn`.
    3.  Check the `CreditsLabel` has updated with the text.
    4.  Optionally, disable `Auto Update` and customize the text.
    5.  Save the scene (even if it shows no changes).


7.  Continue with:

    1.  [Setting up the Main Menu.](/addons/maaacks_game_template/docs/MainMenuSetup.md)  
    2.  [Setting up a Game Scene.](/addons/maaacks_game_template/docs/GameSceneSetup.md)  
    3.  [Loading scenes asynchronously.](/addons/maaacks_game_template/docs/LoadingScenes.md)  
    4.  [Adding icons to the Input Options.](/addons/maaacks_game_template/docs/InputIconMapping.md)  
    5.  [Adding Custom Options.](/addons/maaacks_game_template/docs/AddingCustomOptions.md)
    6.  [Utilizing Game Saving.](/addons/maaacks_game_template/docs/GameSaving.md)  
