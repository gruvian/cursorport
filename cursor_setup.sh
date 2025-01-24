#!/bin/bash

input_dir="$1"  # directory containing the cursor files
dest_dir="$2"   # destination directory inside usr/share/icons

mkdir -p "/usr/share/icons/$dest_dir"
mkdir -p "/usr/share/icons/$dest_dir/cursors"
icons_folder="/usr/share/icons/$dest_dir/cursors"

declare -A cursor_map

# find .inf file
inf_file=$(find "$input_dir" -maxdepth 1 -type f -name "*.inf" | head -n 1)

if [[ -z "$inf_file" ]]; then
    echo "ERROR: No installation .inf file found."
    exit 1
fi

# read .inf file
in_strings_section=false
while IFS='=' read -r key value; do
    key=$(echo "$key" | tr -d '[:space:]')
    value=$(echo "$value" | tr -d '[:space:]' | tr -d '"')  # Remove quotes

    if [[ $key == "[Strings]" ]]; then
        in_strings_section=true
        continue
    elif [[ $key == \[* ]]; then
        in_strings_section=false
    fi

    if $in_strings_section && [[ -n $key && -n $value ]]; then
        value="${value%.cur}"
        value="${value%.ani}"
        cursor_map["$value"]="$key"
    fi
done < "$inf_file"

# debug: print install.inf map
# echo "Cursor map contents:"
# for key in "${!cursor_map[@]}"; do
#    echo "$key -> ${cursor_map[$key]}"
# done

# install.inf remapping of cursor names
for old_name in "${!cursor_map[@]}"; do
    old_file="$input_dir/cursors/$old_name"
    new_name="${cursor_map[$old_name]}"
    renamed_file="$input_dir/cursors/$new_name"

    # debug: check if win2xcur succeeded

    if [[ -f "$old_file" ]]; then
        mv "$old_file" "$renamed_file"
        chmod 644 "$renamed_file"  # ensure the file is accessible
    else
        echo "ERROR: $old_file not found."
    fi
done

# missing X11 names
declare -A additional_mapping
additional_mapping["pointer"]="default arrow mouse left_ptr top_left_arrow left-arrow pointing_hand hand1 e29285e634086352946a0e7090d73106 hand2"
additional_mapping["work"]="working half-busy progress left_ptr_watch 00000000000000020006000e7e9ffc3f 08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599 9116a3ea924ed2162ecab71ba103b17f"
additional_mapping["busy"]="wait watch clock 0426c94ea35c87780ff01dc239897213"
additional_mapping["text"]="xterm ibeam vertical-text crosshair 048008013003cff3c00c801001200000"
additional_mapping["unavailiable"]="unavailable"
additional_mapping["move"]="size_all fleur 4498f0e0c1937ffe01fd06f973665830 9081237383d90e509aa00f00170e968f fcf21c00b30f7e3f83fe0dfd12e71cff dnd-move"
additional_mapping["vert"]="ns-resize size_ver v_double_arrow double_arrow 00008160000006810000408080010102"
additional_mapping["horz"]="ew-resize size_hor sb_h_double_arrow h_double_arrow 028006030e0e7ebffc7f7070c0600140"
additional_mapping["dgn1"]="nwse-resize nw-resize se-resize top_left_corner bottom_right_corner 38c5dff7c7b8962045400281044508d2 c7088f0f3e6c8088236ef8e1e3e70000"
additional_mapping["dgn2"]="nesw-resize ne-resize sw-resize top_right_corner bottom_left_corner 50585d75b494802d0151028115016902 fcf1c3c7cd4491d801f1e1c78f100000"
additional_mapping["link"]="dnd-link alias 0876e1c15ff2fc01f906f1c363074c0f 3085a0e285430894940527032f8b26df 640fb0e74195791501fd1ed57b41487f a2a266d0498c3104214a47bd64ab0fc8"

for base_name in "${!additional_mapping[@]}"; do
    base_file="$input_dir/cursors/$base_name"

    if [[ -f "$base_file" ]]; then
        IFS=$' \t\n' read -r -a mapped_names <<< "${additional_mapping[$base_name]}"
        for mapped_name in "${mapped_names[@]}"; do
            mapped_file="$input_dir/cursors/$mapped_name"
            cp "$base_file" "$mapped_file"
            chmod 644 "$mapped_file" # ensure the file is accessible
        done
    else
        echo "ERROR: $base_file not found."
    fi
done

for file in "$input_dir/cursors/"*; do
    if [[ -f "$file" ]]; then
        cp "$file" "$icons_folder"
        chmod 644 "$icons_folder/$(basename "$file")"  # ensure the file is accessible
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
