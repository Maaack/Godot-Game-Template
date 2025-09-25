# Moving Files

This page covers some tips for rearranging files to a developer's preference.

> [!WARNING]  
> Backup your project before attempting to rearrange files.
> You assume any risk.

## Move Files in Editor

Use the editor to move files around, as this makes sure that `.uid` files get moved with `.gd` files, external resource references will get updated in `.tscn` files, and paths in project settings get updated.

## Update Paths

The flow of scenes in the template by default goes `Opening -> Main Menu -> Game Scene -> Ending Scene`.   

The `Opening` is referenced in the project settings, and will get automatically update if moved in the editor.  

The rest have their default paths stored in the `AppConfig` autoload. The developer can update the paths there if any of them are changed.  

Alternatively, the developer can specify paths in the scenes that reference these other ones by path. These include:
* `opening.tscn`  
* `opening_with_logo.tscn`  
* `main_menu.tscn`  
* `main_menu_with_animations.tscn`  
* `pause_menu.tscn`  
* `game_ui.tscn` (`level_manager.gd`)  
* `end_credits.tscn`  

## Internal Details 

File paths, stored as strings, do not get automatically updated by the editor when their target moves. Paths are used when asynchronous loading of scenes (ie. using `SceneLoader`) is preferred, primarily for memory management.
