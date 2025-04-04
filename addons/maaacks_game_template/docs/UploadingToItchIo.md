# Uploading to itch.io

This is a guide on using *Butler* along with a *Butler Manager* helper script to rapidly upload and deploy your builds to itch.io. It's useful for game jams!  

## Butler

*Butler* is a command-line tool provided by itch.io to upload content to project pages on itch.io.

Get it here: https://itchio.itch.io/butler

After installing it, run `butler login` and go through the login flow. You should only have to do this once.

*Butler* automatically compares builds and only uploads what has changed, so the first upload will take the longest, but every upload after should be faster.

## Exporting

It is recommended to create an `exports/` directory for your builds, add the directory to your `.gitignore` file (if applicable), and also add a `.gdignore` file to the directory to avoid having Godot add `*.import` files to it as well.


## Butler Manager

This script provided at `addons/maaacks_game_template/extras/scripts/butler_manager.sh` can be used to rapidly deploy 4 different builds to your project page. Make sure you can run `bash` shell scripts on your OS. Copy the script into your `exports/` directory and mark it as an executable, if required.  

Run the script with `./butler_manager.sh`. On the first run, it will ask for the destination for uploads. This is a combination of the page owner and the project's URL.  

The Butler Manager will look for directories named the following:  

* HTML5
* Linux
* Windows
* MacOS

Matching directories will be uploaded by *Butler* to their corresponding channels on itch.io. They will then be processed by itch.io servers and eventually appear on the page (usually within 2 minutes).  

The owner of the project page will also get a notification when the builds have finished processing.  

You can re-run `./butler_manager.sh` right after an export from Godot to keep your builds synced.  