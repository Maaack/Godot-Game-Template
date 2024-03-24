#!/bin/bash

short_flag=false

print_usage() {
  printf "Usage: -s"
}

while getopts 's' flag; do
  case "${flag}" in
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
done < <(egrep -ir --include=*.tscn "type=\"AudioStream\"")

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
