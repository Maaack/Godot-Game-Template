# Blending Music Between Scenes

This page covers the `ProjectMusicController`, which is used to blend music in between scenes, that would otherwise abruptly stop the music when they get unloaded.

## Setup

1.  Verify the `Music` audio bus.

    1.  Open the Audio bus editor.
    2.  Confirm that `Music` audio bus is available.
        1.  If the last bus is `New Bus`, try restarting the editor and checking again.
    3.  If the audio bus doesn't exist, add it and save the project.

2.  Verify the `ProjectMusicController` autoload.

    1.  Open the Project Settings.
    2.  Open the `Globals` tab.
    3.  Confirm that the `ProjectMusicController` is listed as an autoload.

3.  Setup music blending between scenes.

    1.  Open up the `project_music_controller.tscn` scene.
    2.  Inspect the root node of the scene tree (`ProjectMusicController`).
    3.  Confirm that the `audio_bus` is set to `Music`.
    4.  Expand the `Blending` variable group.
    5.  Set a `fade_out_duration` or `fade_in_duration`, in seconds.

4.  Add background music to your scenes.

    1.  Import the music asset into the project.
    2.  Add a `BackgroundMusicPlayer`.
    3.  Assign the music asset to the `stream` property.
    4.  Make sure that the `bus` property is set to `Music` and `autoplay` is `true`.
    5.  Save the scene.

## Internal Details 

When a background music player is about to exit the scene tree, it gets reparented to the autoload node. This allows it to continue playing until the next scene is ready and a new background music player is detected. If the audio stream players share the same stream, then the controller will seek the next player to the same position on the stream, before removing the previous one. If a different stream is detected and a fade out duration is set, then the previous player will blend into the next one, by having its volume lowered to zero over the fade out duration.

The autload adds the "BlendMusic" audio bus is added at runtime. If a fade in duration is set, then the temporary bus is used to combine the increasing volume of the player with any other animations local to the scene.

The autoload will work with any `AudioStreamPlayer` with `bus` set to `Music` and `autoplay` set to `true`. These are detected up as they enter the scene tree. To dynamically add an `AudioStreamPlayer` to the background music, call `ProjectMusicController.play_stream(background_music_player)`.