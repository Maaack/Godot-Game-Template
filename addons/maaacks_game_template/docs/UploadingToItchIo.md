# Uploading to itch.io

This is a guide on using *butler* along with a *butler manager* helper script to rapidly upload and deploy your builds to *itch.io*. It's useful for game jams!

## butler

*butler* is a command-line tool provided by *itch.io* to "upload builds of your games quickly & reliably to *itch.io*" (*--itch.io*).

Get it here: https://itchio.itch.io/butler

After installing it, run `butler login` and go through the login flow. You should only have to do this once.

*butler* automatically compares builds and only uploads what has changed, so the first upload will take the longest, but every upload after should be faster.

## Exporting

It is recommended to create an `exports/` directory for your builds, add the directory to your `.gitignore` file (if applicable), and also add a `.gdignore` file to the directory to avoid having Godot add `*.import` files to it as well.

## Butler Manager

This script provided at `addons/maaacks_game_template/extras/scripts/butler_manager.sh` can be used to rapidly deploy 5 different builds to your project page. Make sure you can run `bash` shell scripts on your OS. Copy the script into your `exports/` directory and mark it as an executable, if required.

Run the script with `./butler_manager.sh`. On the first run, it will ask for the the URL of the game page on *itch.io*.

The Butler Manager will look for directories named the following:

- windows
- macos
- linux
- html
- android

Matching directories will be uploaded by *butler* to their corresponding channels on *itch.io*. They will then be processed by *itch.io* servers and eventually appear on the page (usually within a couple of minutes).

The owner of the project page will also get a notification when the builds have finished processing.

You can re-run `./butler_manager.sh` right after an export from *Godot* to keep your builds synced.

### Alternative Pages

The script can take an optional `target` as the first parameter. The default is `default`, so running `./butler_manager.sh default` is the same as `./butler_manager.sh`.

Each target will upload to a distinct *itch.io* URL. For example, run the script `./butler_manager.sh test` and add the URL of your *itch.io* test page. That URL will be recorded and used to upload builds when `target=test`.

## Automating export and publication

You can use *Github Actions* to automate these steps. Look into the `.git/workflows` folder [and this guide](./BuildAndPublish.md).
