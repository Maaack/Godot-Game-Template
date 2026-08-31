![Logo](/addons/plugin_updater/media/icon_256x256.png)
# Godot Plugin Updater

A plugin for updating plugins. Works with Godot plugins hosted on public repositories and using tagged releases.

Currently, only GitHub is supported, but other hosts are planned. Supports plugins for Godot 4.4 through 4.7.1!

## Objective

Provide a generic solution for plugins hosted on open-source repositories to offer automatic updates through the editor.

Any updates available will appear under the **Project > Tools > Update Plugins...** menu item.

![Updates menu location](/addons/plugin_updater/media/updates-location.png)

## Installation

*Plugin Updater* is available in both the *Godot Asset Library* and the *Godot Asset Store*. It is available as a plugin, meaning it can be added to an existing project.

### Existing Project
While editing a project in *Godot*:

1.  Go to the **Asset Store** tab.
2.  Search for "Plugin Updater".
3.  Click on the result to open the plugin details.
4.  Click to **Download**.
5.  Check that contents are getting installed to `addons/` and there are no conflicts.
6.  Click to **Install**.
7.  Complete the installation and extraction.
8.  Enable the plugin from the **Project > Project Settings > Plugins** tab.  

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

func _enable_plugin() -> void:
    PluginUpdater.add_plugin(get_plugin_path(), "https://github.com/{USERNAME}/{REPO_NAME}")

func _disable_plugin() -> void:
	PluginUpdater.remove_plugin(get_plugin_path())
```

#### Supporting Plugin Updater
If you'd rather avoid including the Plugin Updater or making it a dependency, but would still like to optionally support it, you can substitute the following code:

```gdscript
func _enable_plugin() -> void:
	var plugin_repos:Dictionary = ProjectSettings.get_setting("plugin_updater/plugins", {})
	plugin_repos[get_plugin_path()] = "https://github.com/{USERNAME}/{REPO_NAME}"
	ProjectSettings.set_setting("plugin_updater/plugins", plugin_repos)
	ProjectSettings.save()

func _disable_plugin() -> void:
	var plugin_repos:Dictionary = ProjectSettings.get_setting("plugin_updater/plugins", {})
	plugin_repos.erase(get_plugin_path())
	ProjectSettings.set_setting("plugin_updater/plugins", plugin_repos)
	ProjectSettings.save()
```

### External Requests

The `api_client.tscn` and `download_and_extract.tscn` nodes make external requests using the built-in `HTTPRequest` class. These requests are made when the plugin is enabled, or when the editor starts, and during an update.

Here is an example of the request to check for updates for *Plugin Updater*:
```http
GET https://api.github.com/repos/Maaack/Godot-Plugin-Updater/releases
Content-Type: application/json
```
Here is an example of the request to update to the latest release of *Plugin Updater*:
```http
GET https://api.github.com/repos/Maaack/Godot-Plugin-Updater/zipball/v0.5.0
```

### Testing

The `check_plugin_version.tscn` and `update_plugin.tscn` can both be tested manually in the inspector, given a plugin directory and repository URL.

Open up either scene, select the root note in the Scene Tree, and then in the Inspector, fill in the `Plugin Directory` and `Plugin Repo URL`. Then press the button to test the scene.

`check_plugin_version.tscn` will print output to the console.

`update_plugin.tscn` will make a window visible inside the scene with the requested update information.