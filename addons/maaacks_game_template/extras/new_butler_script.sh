#!/bin/bash

# This script is used to upload multiple builds of a Godot project to itch.io with `butler`.

channels=("win" "mac" "linux" "html5" "android")
directories=("windows" "macos" "linux" "html" "android")
target="default"
source_file="butler_source.txt"
target_key=""

# Get specific target from input variable "target" (default = "default")
if [ $# -gt 0 ]; then
  target=$1
fi
target_key="url_$target"

# Check for the source file and load it if it exists.
if [ -e "$source_file" ]; then
  source "$source_file"
fi

# If the url variable is still empty, ask the user.
if [ -z "${!target_key}" ]; then
  page_url=""
  read -p "What is game page URL? " -r page_url
  if [[ "$page_url" =~ ^https?://([^.]+).itch.io/(.+) ]]; then
    eval $target_key="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  fi
  echo ${!target_key}
fi

# Save the new values of the variables back into the file
for i in "${!url_@}"; do
  printf '%s=%q\n' "$i" "${!i}"
done > $source_file

len=${#channels[@]}

for((i=0; i<$len; i++)); do
  channel="${channels[i]}"
  directory="${directories[i]}"
  if [ -d "$directory" ]; then
    echo butler push $directory/ ${!target_key}:$channel
    butler push $directory/ ${!target_key}:$channel
  else
    echo "The directory \`$directory\` did not exist."
  fi 
done

