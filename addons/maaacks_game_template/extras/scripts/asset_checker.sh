#!/bin/bash
# asset checker command
# Used for quickly checking that assets (like audio files) are being used where expected.
# 
# Recursively searches through scene files (.tscn, .scn, .res)
# for occurrences of asset types (default: AudioStream).
# It then outputs the paths of assets discovered,
# along with the file names that use them.

short_flag=false
asset_type="AudioStream"

print_usage() {
  printf "Usage: -sa %s\n" "$asset_type"
}

while getopts 'a:s' flag; do
  case "${flag}" in
    a) 
       asset_type="${OPTARG}"
       ;;
    s) 
       short_flag=true
       ;;
    *) 
       print_usage
       exit 1 
       ;;
  esac
done

# Initialize an associative array to store paths and corresponding files
declare -A path_files

while IFS=: read -r file line; do
    path=$(echo "$line" | grep -o 'path="[^"]*' | cut -d'"' -f2)
    if [ -n "$path" ]; then
        # Append the current file to the string of files for this path
        # Note: Bash does not support having arrays as values of associative array.
        # Using a pipe `|` separator instead, and then splitting on output
        if [ -z "${path_files["$path"]}" ]; then
            path_files["$path"]=$file
        else
            path_files["$path"]+="|$file"
        fi
    fi
done < <(egrep -ir --include=*.{tscn,scn,res} "type=\"$asset_type\"")

# Get the paths and sort them
sorted_paths=()
for key in "${!path_files[@]}"; do
    sorted_paths+=("$key")
done
IFS=$'\n' sorted_paths=($(sort <<< "${sorted_paths[*]}"))
unset IFS

# Print out the results
for path in "${sorted_paths[@]}"; do
    # Note: Bash does not support having arrays as values of associative array.
    # Splitting the concatenated files string on the pipe `|` separator.
    IFS='|' read -r -a files_array <<< "${path_files[$path]}"
    files_count=${#files_array[@]}
    printf "%-80s | Uses: %s\n" "$path" "$files_count"
    if ! $short_flag ; then
        for file in "${files_array[@]}"; do
            printf "\t%82s\n" "$file"
        done
        echo
    fi
done
