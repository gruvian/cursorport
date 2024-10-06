#!/bin/bash

input_dir="$1"  # directory containing the cursor files
dest_dir="$2"   # destination directory inside usr/share/icons

mkdir -p "/usr/share/icons/$dest_dir"
mkdir -p "/usr/share/icons/$dest_dir/cursors"
icons_folder="/usr/share/icons/$dest_dir/cursors"

declare -A cursor_map

# check for hidden file
if [[ -f "$input_dir/Install.inf" ]]; then
    inf_file="$input_dir/Install.inf"
elif [[ -f "$input_dir/.Install.inf" ]]; then
    inf_file="$input_dir/.Install.inf"
else
    echo "No Install.inf file found."
    exit 1
fi

while IFS='=' read -r key value; do
    # spaces in install.inf
    key=$(echo "$key" | tr -d '[:space:]') 
    value=$(echo "$value" | tr -d '[:space:]')  

    if [[ $value == -* ]]; then
        new_name="${key}.cur"
        cursor_map["$value"]="$new_name"
    fi
done < <(grep -E '^[^-]' "$inf_file" | sed 's/\(.*\)=\(.*\)/\1=\2/')

# install.inf remapping
for old_name in "${!cursor_map[@]}"; do
    old_file="$input_dir/$old_name"
    new_name="${cursor_map[$old_name]}" 
    renamed_file="$input_dir/cursors/$new_name" 

    if [[ -f "$old_file" ]]; then
        mv "$old_file" "$renamed_file"  
        echo "Renamed $old_file to $renamed_file"
    fi
done

# copies for X11 naming conventions
declare -A additional_mapping
additional_mapping["pointer"]="default arrow mouse left_ptr"
additional_mapping["work"]="working half-busy progress"
additional_mapping["busy"]="wait"
additional_mapping["text"]="xterm"
additional_mapping["unavailable"]="unavailable"
additional_mapping["vert"]="ns-resize"
additional_mapping["horz"]="ew-resize sb_h_double_arrow"
additional_mapping["dgn1"]="nwse-resize nw-resize se-resize"
additional_mapping["dgn2"]="nesw-resize ne-resize sw-resize"
additional_mapping["link"]="fleur"

for base_name in "${!additional_mapping[@]}"; do
    base_file="$input_dir/cursors/$base_name" 

    if [[ -f "$base_file" ]]; then
        #remove spaces
        IFS=' ' read -r -a mapped_names <<< "${additional_mapping[$base_name]}"
        for mapped_name in "${mapped_names[@]}"; do
            mapped_file="$input_dir/cursors/$mapped_name"
            cp "$base_file" "$mapped_file"
            echo "Copied $base_file to $mapped_file"
        done
    else
        echo "Base file $base_file not found. Skipping additional mappings for $base_name."
    fi
done

for file in "$input_dir/cursors/"*; do
    if [[ -f "$file" ]]; then
        cp "$file" "$icons_folder"
        echo "Copied $file to $icons_folder"
    fi
done

name_of_dir="$dest_dir"

cat <<EOL > "/usr/share/icons/$dest_dir/index.theme"
[Icon Theme]
Name=$name_of_dir
EOL

cat <<EOL > "/usr/share/icons/$dest_dir/cursor.theme"
[Icon Theme]
Inherits=$name_of_dir
EOL

echo "Cursor renaming, copying with additional mappings, and theme files creation completed."
