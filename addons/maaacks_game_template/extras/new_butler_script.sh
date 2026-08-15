#!/bin/bash

# This script is used to upload multiple builds of a Godot project to itch.io with `butler`.

channels=("win", "mac", "linux", "html5", "android")
channel_folders=("windows", "macos", "linux", "html", "android")
target="default"
source_file="butler_source.txt"
target_key=""

# Get specific target from input variable "target" (default = "default")
if [ $# -gt 0 ]; then
  target=$1
fi
target_key="url_$target"

# Check for the existance of the variables file and create it if not
if [ -e "$source_file" ]; then
  echo "file exists"
  source "$source_file"
fi

echo $target_key
echo ${!target_key}

# If the url variable is still empty, ask the user.
if [ -z "${!target_key}" ]; then
  page_url=""
  read -p "What is game page URL? " -r page_url
  if [[ "$page_url" =~ ^https?://([^.]+).itch.io/(.+) ]]; then
    eval $target_key="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  fi
  echo ${!target_key}
fi



# Save the user input into the variable

# Save the new values of the variables back into the file
for i in "${!url_@}"; do
  printf '%s=%q\n' "$i" "${!i}"
done > $source_file

# Loop through channel_folders

# Check if channel folder exists in directory (case-insensitive)

# Push the folder through butler through the matching channel
