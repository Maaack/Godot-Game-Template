# Adding UI Sound Effects

This page covers adding sound effects to common UI elements like buttons and sliders.

1.  Verify the `Music` and `SFX` audio busses.

    1.  Open the Audio bus editor.
    2.  Confirm that `Music` and `SFX` audio busses are available.
        1.  If the last bus is `New Bus`, try restarting the editor and checking again.
    3.  If the audio bus doesn't exist, add it and save the project.


1.  Add UI sound effects:
    1.  By scene.


        1.  Open `main_menu_with_animations.tscn` and `pause_menu.tscn`.
        2.  In the Scene Tree, select the `UISoundController` node.
        3.  In the Inspector, add audio streams to the various UI node events.
        4.  Save the scenes.  


    2.  Project-wide.


        1.  Open `project_ui_sound_controller.tscn`.
        2.  In the Scene Tree, select the `UISoundController` node.
        3.  In the Inspector, add audio streams to the various UI node events.
        4.  Save the scene.  
