# Basic Setup

These instructions cover the basics for setting up the template.

## Setup Wizard

The _Setup Wizard_ shows the user's progress through the setup process.

### Open

Open the _Setup Wizard_ by navigating to `Project > Tools > Run Maaack's Game Template Setup...`.

![Setup Wizard Location](/addons/maaacks_game_template/media/setup-wizard-location.png)

### Check & Complete

A typical full installation will have the following steps completed:  
-  Using Latest Version
-  Copy Example Files
-  Update Project Paths
-  Delete Example Files
-  Set Main Scene

![Setup Wizard Window](/addons/maaacks_game_template/media/setup-wizard-window.png)

Depending on how the template was installed, or if any issues occurred, some of these may need to be run from the wizard to be completed.

The remaining steps are optional customizations.

## Scene Paths

The flow of scenes in the template is (by default):  
```
Opening -> Main Menu -> Game Scene -> Ending Scene
```   

To change the _Main Menu_, _Game Scene_, or _Ending Scene_:

1.  Open the **Project > Project Settings > General** tab.
2.  Set **Advanced Settings** to enabled.
3.  Navigate to the *Maaacks Game Template* settings.
4.  Update `Main Menu Scene Path` to the main menu scene (`main_menu.tscn` by default).  
5.  Update `Game Scene Path` to the game scene (`game.tscn` by default).  
6.  Update `Ending Scene Path` to the ending scene (`end_credits.tscn` by default).  
7.  Close the window.
    
To change the _Opening_:

1.  Navigate to `Project > Project Settings…`
2.  In the _Project Settings_ window, go to the `General` tab.
3.  In the settings list, navigate to `Application > Run`.
4.  Update `Main Scene` to the desired path.

## Next Steps

### Recommended
1.  [Main Menu Setup](/addons/maaacks_game_template/docs/MainMenuSetup.md)  
2.  [Options Menu Setup](/addons/maaacks_game_template/docs/OptionsMenuSetup.md)  
3.  [Game Scene Setup](/addons/maaacks_game_template/docs/GameSceneSetup.md)  
4.  [Updating Credits](/addons/maaacks_game_template/docs/UpdatingCredits.md)  
5.  [Blending Music](/addons/maaacks_game_template/docs/BlendingMusic.md)  
6.  [Adding UI Sound Effects](/addons/maaacks_game_template/docs/AddingUISFX.md)  

### Extra
1.  [Adding Icons to the Input Options](/addons/maaacks_game_template/docs/InputIconMapping.md)  
2.  [Supporting Joypad Inputs](/addons/maaacks_game_template/docs/JoypadInputs.md)  
3.  [Loading scenes asynchronously](/addons/maaacks_game_template/docs/LoadingScenes.md)  
4.  [Utilizing Game Saving](/addons/maaacks_game_template/docs/GameSaving.md)  
5.  [Uploading to itch.io](/addons/maaacks_game_template/docs/UploadingToItchIo.md)  