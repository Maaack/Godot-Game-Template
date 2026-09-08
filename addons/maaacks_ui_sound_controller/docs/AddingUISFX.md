# Adding UI Sound Effects

This page covers *UISoundController*, a node used for adding sound effects to common UI elements like buttons and sliders. *ProjectUISoundController* is an autoload used to dynamically add sound effects to every scene.

1.  Verify the *SFX* audio bus.

    1.  Open the Audio bus editor.
    2.  Confirm that *SFX* audio bus is available.  
        -  If the last bus is *New Bus*, try restarting the editor and checking again.
        -  If the audio bus doesn't exist, add it and save the project.

1.  Add UI sound effects:
    1.  By scene.

        1.  In the Scene Tree of a UI scene, add a *Node* to the root node.
        2.  Attach the `ui_sound_controller.gd` script to the node.
        3.  In the Inspector, add audio streams to the various UI node events.
        4.  Save the scenes.  

    2.  Project-wide.

        1.  Open `project_ui_sound_controller.tscn`.
        2.  In the Scene Tree, select the *UISoundController* node.
        3.  In the Inspector, add audio streams to the various UI node events.
        4.  Save the scene.  


## Internal Details 

When a node gets added to the scene, *UI Sound Controller* checks that it is one of the compatible nodes that can have attached SFX. If it is, then it connects methods to play from common audio streams when the various signals are emitted.