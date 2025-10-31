#!/bin/bash
# butler manager command
# Uploads directories as builds to matching itch.io channels.
# HTML5 => html5
# Linux => linux
# Windows => win
# MacOS => osx

file=upload_destination.txt
directories=("HTML5" "Linux" "Windows" "MacOS")
channels=("html5" "linux" "win" "osx")

# Check if the file exists
if [ ! -e $file ]; then
    # File doesn't exist, create an empty one
    touch $file
fi

# File exists, read the first line into a variable
read -r destination < $file
    
if [ -z "$destination" ]; then
    # File is empty, prompt the user for input
    echo "Please enter the build destination (username/project-url-after-slash)."
    read -r user_input
    
    # Save user input to the file
    echo "$user_input" > "$file"
    echo "Destination saved to $file."
    destination="$user_input"
fi

# Check for the existence of directories and upload contents
for ((i=0; i<${#directories[@]}; i++)); do
    dir="${directories[i]}"
    channel="${channels[i]}"
    
    if [ -d "$dir" ]; then
        echo butler push ./$dir/ $destination:$channel
        butler push ./$dir/ $destination:$channel
    else
        echo "Directory '$dir' does not exist."
    fi
done