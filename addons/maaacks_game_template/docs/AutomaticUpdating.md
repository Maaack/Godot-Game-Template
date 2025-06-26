# Automatic Updating

This plugin automatically checks the GitHub repo for a new release when the plugin is enabled (on each run of the Editor). When an update is available, the option to update will appear in the `Project > Tools` menu.

## Starting an Update

> [!IMPORTANT]  
> Save the state of the project, and close all open scenes and scripts.

Select the option from `Project > Tools > Update Maaack's Game Template to ...`.

A window will pop-up, confirming the choice to update to the latest release. Select `OK`.

A progress bar will appear showing the progress through downloading, saving, and extracting.

This effectively deletes the current `addons/maaacks_game_template` folder and replaces it with a new one. Nothing outside of `addons/` should be affected.

After, a confirmation box should appear confirming a successful update.

## Disabling Automatic Checking

You can disable the automatic update checks by going into the Project Settings, and enabling the `maaacks_game_template/disable_update_check` setting. You can then close the window.