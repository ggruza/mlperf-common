#!/bin/bash
if ! [ "$#" -eq 2 ]; then
    echo "Error: get-mount-info.sh takes 2 arguments: 1) paths to verify 2) output path"
    exit 1
fi

OLD_IFS=$IFS
IFS=","
for dir_path in $1; do
    if ! [ -d "$dir_path" ]; then
        echo "Error: path $dir_path is incorrect"
        exit 1
    fi
done

mkdir -p "$2"
touch "$2/cont-mount-info.sh"
exec > "$2/cont-mount-info.sh"
echo "declare -a directory_sizes"
echo "declare -a number_of_paths_in_dir"

for dir_path in $1; do
    echo "# ----------"
    echo "directory_sizes+=("
    dir_size=$(du -sk "$dir_path" | cut -f1)
    num_files=$(ls -1 "$dir_path" | wc -l)
    echo "\",$dir_size,$num_files\""
    dir_counter=1
    while IFS= read -r subdir; do
        relative_path="${subdir#$dir_path/}"
        subdir_size=$(du -sk "$subdir" | cut -f1)
        num_files=$(ls -1 "$subdir" | wc -l)
        echo "\"$relative_path,$subdir_size,$num_files\""
        ((dir_counter++))
    done < <(find "$dir_path" -mindepth 1 -type d ! -path '*/.*' | awk -v dir_path="$dir_path" -F'/' '{print NF-1, $0}' | sort -n | cut -d' ' -f2-)
    echo ")"
    echo "number_of_paths_in_dir+=($dir_counter)"
done
IFS=$OLD_IFS