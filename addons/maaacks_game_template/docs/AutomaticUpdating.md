# Automatic Updating

This plugin automatically checks GitHub for new releases. When a new release is available, the option to update will appear in the `Project > Tools` menu.

## Starting an Update

> [!IMPORTANT]  
> Save the state of the project, and close all open scenes and scripts.

Select the option from `Project > Tools > Update Maaack's Game Template to v...`.

A window will pop-up, confirming the choice to update to the latest release. Select `OK`.

Another window will show progress through downloading, saving, and extracting.

This effectively deletes the current `addons/maaacks_game_template/` folder and replaces it with a new one. Nothing outside of `addons/` should be affected.

After, a window should appear confirming a successful update.

## Disabling Automatic Checking

You can disable the automatic update checks by going into the Project Settings, and enabling the `maaacks_game_template/disable_update_check` setting. You can then close the window.

## Issues

If the option to update does not appear, try restarting the editor, or re-enabling the plugin.

Updating adds the examples folder into the `addons/maaacks_game_template/` folder, if it had been deleted previously.

Files already copied from the examples folder will not be affected by an update. However, a mismatch of versions may cause issues, too. If there are no major customizations to the copied files, it is recommended to delete them and recopy from `Project > Tools > Copy Maaack's Game Template Examples...`.