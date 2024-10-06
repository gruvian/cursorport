#!/bin/bash

input_dir="$1"  # Directory containing the cursor files
dest_dir="$2"   # Destination directory where the cursors will be stored

# Create the destination directory if it doesn't exist
mkdir -p "/usr/share/icons/$dest_dir"
mkdir -p "/usr/share/icons/$dest_dir/cursors"
icons_folder="/usr/share/icons/$dest_dir/cursors"

# Read the Install.inf file to create an associative array
declare -A cursor_map

# Read the Install.inf file and populate the cursor_map
while IFS='=' read -r key value; do
    # Clean up the key and value
    key=$(echo "$key" | tr -d '[:space:]')  # Remove spaces
    value=$(echo "$value" | tr -d '[:space:]')  # Remove spaces

    # If key has a prefix of "-", append ".cur" to the value
    if [[ $value == -* ]]; then
        new_name="${key}.cur"
        cursor_map["$value"]="$new_name"
    fi
done < <(grep -E '^[^-]' "$input_dir/Install.inf" | sed 's/\(.*\)=\(.*\)/\1=\2/')

# Step to rename the files
for old_name in "${!cursor_map[@]}"; do
    old_file="$input_dir/$old_name"
    new_name="${cursor_map[$old_name]}"  # New name from the mapping
    renamed_file="$input_dir/cursors/$new_name"  #populate cursors dir

done

# Step to copy renamed files to the destination folder
for file in "$input_dir/cursors/"*; do
    # Check if the file exists to avoid errors
    if [[ -f "$file" ]]; then
        cp "$file" "$icons_folder"  # Copy the file to the destination
        echo "Copied $file to $icons_folder"  # Log the action
    else
        echo "File $file does not exist. Skipping."  # Log if the file doesn't exist
    fi
done


# Create index.theme and cursor.theme files in the destination directory
name_of_dir="$dest_dir"

# Create index.theme file
cat <<EOL > "/usr/share/icons/$dest_dir/index.theme"
[Icon Theme]
Name=$name_of_dir
EOL

# Create cursor.theme file
cat <<EOL > "/usr/share/icons/$dest_dir/cursor.theme"
[Icon Theme]
Inherits=$name_of_dir
EOL

echo "Cursor renaming, copying, and theme files creation completed."
