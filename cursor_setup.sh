#!/bin/bash

input_dir="$1"  # Directory containing the cursor files
dest_dir="$2"   # Destination directory where the cursors will be stored

mkdir -p "/usr/share/icons/$dest_dir"
mkdir -p "/usr/share/icons/$dest_dir/cursors"
icons_folder="/usr/share/icons/$dest_dir/cursors"

# Read the Install.inf file
declare -A cursor_map


while IFS='=' read -r key value; do
    key=$(echo "$key" | tr -d '[:space:]') 
    value=$(echo "$value" | tr -d '[:space:]')  

    if [[ $value == -* ]]; then
        new_name="${key}.cur"
        cursor_map["$value"]="$new_name"
    fi
done < <(grep -E '^[^-]' "$input_dir/Install.inf" | sed 's/\(.*\)=\(.*\)/\1=\2/')

for old_name in "${!cursor_map[@]}"; do
    old_file="$input_dir/$old_name"
    new_name="${cursor_map[$old_name]}" 
    renamed_file="$input_dir/cursors/$new_name"  #populate cursors dir

done


for file in "$input_dir/cursors/"*; do
    if [[ -f "$file" ]]; then
        cp "$file" "$icons_folder" 
        echo "Copied $file to $icons_folder"  
    else
        echo "File $file does not exist. Skipping."  
    fi
done


name_of_dir="$dest_dir"

#index.theme
cat <<EOL > "/usr/share/icons/$dest_dir/index.theme"
[Icon Theme]
Name=$name_of_dir
EOL

#cursor.theme
cat <<EOL > "/usr/share/icons/$dest_dir/cursor.theme"
[Icon Theme]
Inherits=$name_of_dir
EOL

echo "Cursor renaming, copying, and theme files creation completed."
