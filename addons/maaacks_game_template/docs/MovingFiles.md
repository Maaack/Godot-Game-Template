# Moving Files

This page covers some tips for rearranging files to an individual developer's preference.

> [!WARNING]  
> Backup your project before attempting to rearrange files.  
> You assume any risk.

## Move Files in the Editor

Use the editor to move files around, as this makes sure that `.uid` files get moved with `.gd` files, external resource references will get updated in `.tscn` files, and paths in project settings get updated.

UIDs do help with moving files outside of the editor, but not all scenes will have UIDs set if they've just recently been copied from the examples.

## Update File Paths

The flow of scenes in the template by default goes `Opening -> Main Menu -> Game Scene -> Ending Scene`.   

The `Opening` is referenced in the project settings, and will get automatically update if moved in the editor.  

The rest have their default paths stored in the `AppConfig` autoload. These do not get automatically updated, so the developer must update these paths if they change.  

Alternatively, the developer can specify paths in the scenes that reference the other scenes by path. These include:
* `opening.tscn`  
* `main_menu.tscn`  
* `main_menu_with_animations.tscn`  
* `pause_menu.tscn`  
* `game_ui.tscn` (`level_manager.gd`)  
* `end_credits.tscn`  

Any file paths in these scenes left blank will default to the values in `AppConfig`.

## Internal Details 

File paths, stored as strings, do not get automatically updated by the editor when their target moves. Paths are used when asynchronous loading of scenes (ie. using `SceneLoader`) is preferred, primarily for memory management.
