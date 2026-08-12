# Automatic Updating

This plugin supports automatic updating with the *[Plugin Updater](https://github.com/Maaack/Godot-Plugin-Updater)*. *Plugin Updater* is installed in `/addons/` alongside this plugin, and must also be enabled in the **Project > Project Settings > Plugins** tab to function.

> [!NOTE]  
> The input prompts installer depends on the Plugin Updater being installed in the same project. The Plugin Updater does *not* need to be enabled for the input prompts installer to function.

## Starting an Update

> [!IMPORTANT]  
> Save the state of the project, and close all open scenes and scripts.

If an update is available, then the option to update will be available at **Project > Tools > Update Plugins... > Maaack's Game Template to v...**.

Selecting the option will make a window pop-up, confirming the choice to update to the latest release. Select **OK**.

Another window will show progress through downloading, saving, and extracting.

This effectively deletes the current `addons/maaacks_game_template/` folder and replaces it with a new one. Nothing outside of `addons/` should be affected.

After extracting finishes, a window should appear confirming a successful update.

## Disabling Automatic Checking

You can disable the automatic update checks entirely by disabling the Plugin Updater in the **Project > Project Settings > Plugins** tab.

To disable automatic updates by plugin, go into the **Project > Project Settings > General** tab, and remove the entries in the `plugin_updater/plugins` setting (ex. `"res://addons/maaacks_game_template/"`). You can then close the window.

## Issues

If the option to update does not appear, try restarting the editor, or re-enabling *Plugin Updater*.