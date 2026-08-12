![Logo](/addons/plugin_updater/media/icon_256x256.png)
# Godot Plugin Updater

A plugin for updating plugins. Works with Godot plugins hosted on public repositories and using tagged releases.

Currently, only GitHub is supported, but other hosts are planned. Supports plugins for Godot 4.4 through 4.7.1!

## Objective

Provide a generic solution for plugins hosted on open-source repositories to offer automatic updates through the editor.

Any updates available will appear under the **Project > Tools > Update Plugins...** menu item.

![Updates menu location](/addons/plugin_updater/media/updates-location.png)

## Installation

### GitHub


1.  Download the latest release version from [GitHub](https://github.com/Maaack/Godot-Plugin-Updater/releases/latest).  
2.  Extract the contents of the archive.
3.  Move the `addons/plugin_updater` folder into your project's `addons/` folder.  
4.  Open/Reload the project.  
5.  Enable the plugin from the **Project > Project Settings > Plugins** tab.  


## Usage

### Automatic Updates
When Plugin Updater is enabled, or whenever the editor starts, it will check the plugins in the project setting `"plugin_updater/plugins"`, compare against the latest releases, and offer the option to update plugins in the **Project > Tools > Update Plugins...** menu item.

### Adding A Plugin / Repo
Open the script of the plugin that you want to have automatic updates. This can be found in the plugin's configuration file (ex. `plugin.cfg`) under the `script` property (ex. `script="plugin.gd"`).

#### Including Plugin Updater
If you are going to include the Plugin Updater with your plugin, then just add the following code:
```gdscript
func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func _add_to_auto_update_list() -> void:
    PluginUpdater.add_plugin(get_plugin_path(), "https://github.com/{USERNAME}/{REPO_NAME}")

func _remove_from_auto_update_list() -> void:
	PluginUpdater.remove_plugin(get_plugin_path())

func _enter_tree() -> void:
	_add_to_auto_update_list()

func _exit_tree() -> void:
	_remove_from_auto_update_list()
```

#### Supporting Plugin Updater
If you'd rather avoid including the Plugin Updater or making it a dependency, but would still like to optionally support it, you can substitute the following code:

```gdscript
func _add_to_auto_update_list() -> void:
	var plugin_repos:Dictionary = ProjectSettings.get_setting("plugin_updater/plugins", {})
	plugin_repos[get_plugin_path()] = PLUGIN_REPO_URL
	ProjectSettings.set_setting("plugin_updater/plugins", plugin_repos)

func _remove_from_auto_update_list() -> void:
	var plugin_repos:Dictionary = ProjectSettings.get_setting("plugin_updater/plugins", {})
	plugin_repos.erase(get_plugin_path())
	ProjectSettings.set_setting("plugin_updater/plugins", plugin_repos)
```

### Testing

The `check_plugin_version.tscn` and `update_plugin.tscn` can both be tested manually in the inspector, given a plugin directory and repository URL.

Open up either scene, select the root note in the Scene Tree, and then in the Inspector, fill in the `Plugin Directory` and `Plugin Repo URL`. Then press the button to test the scene.

`check_plugin_version.tscn` will print output to the console.

`update_plugin.tscn` will make a window visible inside the scene with the requested update information.