# Loading Scenes

These are instructions for using the `SceneLoader` autoload to load resources asynchronously. This is especially useful for large scenes, but can be used throughout a project. The plugin comes with an example loading screen as well.

## Foreground Loading

By default, calling `SceneLoader.load_scene(path_to_scene)` will unload the current scene and replace it with a loading screen, until the next scene is fully loaded. At that point, the loading screen will be removed and replaced with the next scene.

It is intended to replace calls to `get_tree().change_scene_to_file(path_to_scene)` that open large scenes and may cause a stutter. It can also replace calls to `get_tree().change_scene_to_packed(loaded_packed_scene)`, that may require large scenes to already be loaded into memory.

## Background Loading

Calling `SceneLoader.load_scene(path_to_scene, true)` will load the scene in the background (hence the `in_background` argument being set to `true`).

There are a number of ways to then show the scene when it is ready, or even switch to foreground loading in case it is not.

### Signal When Loaded

A scene can be loaded as soon as it is ready, by listening for the `scene_loaded` signal from the `SceneLoader`.

An example of this is in `level_loader.gd` of [Maaack's Game Template](https://github.com/Maaack/Godot-Game-Template/blob/main/addons/maaacks_game_template/extras/scripts/level_loader.gd), which loads scenes in the background and displays a loading screen, but doesn't change the whole scene when the next one is ready. Instead, it loads the next level into a container.  


Below is an example of reacting to `SceneLoader` signals to open the loaded scene in an optional `container` node, or switch to it entirely.  

```
SceneLoader.load_scene(path_to_scene, true)
await SceneLoader.scene_loaded
if container:
    # Has a container, so will open the loaded scene in it
    var resource = SceneLoader.get_resource()
    var instance = resource.instantiate()
    container.add_child(instance)
else:
    # Has no container, so will switch to the loaded scene
    SceneLoader.change_scene_to_resource()
```

### On User Input or a Timed Event

A scene could load the next scene based on a timer, or when the player indicates that they are ready.  

An example is in `opening.gd` of [Maaack's Game Template](https://github.com/Maaack/Godot-Game-Template/blob/main/addons/maaacks_game_template/base/nodes/opening/opening.gd), which starts loading the main menu immediately, and switches to it when its animations finish. Player's input can speed them up the animations, so by the end, if the next scene is not ready, a loading screen can be shown instead.  

Below is an example of starting the load of the next scene.  

```
func _ready() -> void:
    # Immediately starting to load the next scene in the background
	SceneLoader.load_scene(path_to_scene, true)
```

Below is an example of reacting to the player's input to either show the next scene or a loading screen.  

```
func _unhandled_input(event : InputEvent) -> void:
    var status = SceneLoader.get_status()
    if status != ResourceLoader.THREAD_LOAD_LOADED:
        # Resource is not loaded, so show the loading screen
        SceneLoader.change_scene_to_loading_screen()
    else:
        # Resource is loaded, so switch to the loaded scene
        SceneLoader.change_scene_to_resource()
```
