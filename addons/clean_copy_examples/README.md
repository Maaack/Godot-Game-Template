![Logo](/addons/clean_copy_examples/media/icon_256x256.png)
# Godot Clean Copy Examples

A tool used to copy example files out of `addons/` folders into the destination of the user's choosing, cleaning up UIDs in the process.

See the setup wizard in *[Maaack's Game Template](https://github.com/Maaack/Godot-Game-Template)* for an example of how it is used.

## Objective

Provide a generic solution copying examples from multiple plugins into a single destination, and managing the clean-up of the original example files.

## Installation

*Clean Copy Examples* is available in the *Godot Asset Library*. It is available as a plugin, meaning it can be added to an existing project.

### Existing Project
While editing a project in *Godot*:

1.  Go to the **Asset Store** tab.
2.  Search for "Clean Copy Examples".
3.  Click on the result to open the plugin details.
4.  Click to **Download**.
5.  Check that contents are getting installed to `addons/` and there are no conflicts.
6.  Click to **Install**.
7.  Complete the installation and extraction.

## Usage

### Adding An Examples Folder
Open the script of the plugin that you want to support copying examples. This can be found in the plugin's configuration file (ex. `plugin.cfg`) under the `script` property (ex. `script="plugin.gd"`).

#### Including Clean Copy Examples
If you are going to include the *Clean Copy Examples* with your plugin, then just add the following code:
```gdscript
func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"

func _enable_plugin() -> void:
    CleanCopyExamples.add_examples(get_plugin_path() + "examples/relative/path/")

func _disable_plugin() -> void:
	CleanCopyExamples.remove_examples(get_plugin_path() + "examples/relative/path/")
```

#### Supporting Clean Copy Examples
If you'd rather avoid including the *Clean Copy Examples* or making it a dependency, but would still like to optionally support it, you can substitute the following code:

```gdscript
func _enable_plugin() -> void:
	var default_value : Array[String] = []
	var examples_paths : Array[String] = ProjectSettings.get_setting("clean_copy_examples/examples_paths", default_value)
	examples_paths.append(get_plugin_path() + "examples/relative/path/")
	ProjectSettings.set_setting("clean_copy_examples/examples_paths", examples_paths)
	ProjectSettings.save()

func _disable_plugin() -> void:
	var default_value : Array[String] = []
	var examples_paths : Array[String] = ProjectSettings.get_setting("clean_copy_examples/examples_paths", default_value)
	examples_paths.erase(get_plugin_path() + "examples/relative/path/")
	ProjectSettings.set_setting("clean_copy_examples/examples_paths", examples_paths)
	ProjectSettings.save()
```

### Copying Examples
For the sake of simplicity, the tool does not display windows on its own. It assumes another editor plugin or scene will load the window and add it as a child to themselves:

```gdscript
func _on_copy_and_clean_files_completed(target_path : String) -> void:
	# Custom logic after successful copying
	pass

func open_copy_and_clean_files_dialog() -> void:
	var copy_and_clean_files_instance := CleanCopyExamples.get_copy_and_clean_scene()
	copy_and_clean_files_instance.completed.connect(_on_copy_and_clean_files_completed)
	add_child(copy_and_clean_files_instance)
```
