function __epub_rename_target --argument-names out_dir name
    set -l target "$out_dir/$name"
    if not test -e "$target"
        echo "$target"
        return 0
    end

    set -l stem (string replace -r -i '\.epub$' '' -- "$name")
    set -l index 2

    while true
        set target "$out_dir/$stem-$index.epub"
        if not test -e "$target"
            echo "$target"
            return 0
        end
        set index (math $index + 1)
    end
end

function __epub_rename_metadata_name --argument-names file
    set -l function_file (functions --details epub_rename 2>/dev/null)
    if test -z "$function_file"
        return 1
    end

    set -l helper_script (path dirname -- "$function_file")/epub_agg_metadata.py
    if not test -f "$helper_script"
        return 1
    end

    python3 "$helper_script" "$file" 2>/dev/null
end

function __epub_rename_apply_metadata_name --argument-names out_dir file
    set -l metadata_name (__epub_rename_metadata_name "$file")
    if test -z "$metadata_name"
        set metadata_name (basename "$file")
    end

    if test "$metadata_name" = (basename "$file"); and test (path dirname -- "$file") = "$out_dir"
        echo "$file"
        return 0
    end

    set -l target (__epub_rename_target "$out_dir" "$metadata_name")
    if mv "$file" "$target"
        echo "$target"
        return 0
    end

    echo "Failed to rename $file using epub metadata" >&2
    echo "$file"
    return 1
end

function epub_rename --description 'rename epub files from metadata and move them into a dated processed directory'
    if test (count $argv) -gt 1
        echo "Usage: epub_rename [source_dir]"
        return 1
    end

    set -l src "$HOME/downloads/functional"
    if test (count $argv) -eq 1
        set src $argv[1]
    end

    if not test -d "$src"
        echo "Directory not found: $src" >&2
        return 1
    end

    set src (path resolve -- "$src")

    set -l epubs (find "$src" -mindepth 1 -maxdepth 1 -type f -iname '*.epub' -print)
    if test (count $epubs) -eq 0
        echo "No epub files found in $src"
        return 1
    end

    set -l stamp (date +%F)
    set -l out_dir "$src/processed-$stamp"
    set -l dir_index 2

    while test -e "$out_dir"
        set out_dir "$src/processed-$stamp-$dir_index"
        set dir_index (math $dir_index + 1)
    end

    mkdir -p "$out_dir"
    or begin
        echo "Failed to create $out_dir" >&2
        return 1
    end

    set -l moved 0
    set -l metadata_renamed 0
    set -l skipped 0

    for file in $epubs
        set -l metadata_name (__epub_rename_metadata_name "$file")
        if test -n "$metadata_name"; and test "$metadata_name" != (basename "$file")
            set metadata_renamed (math $metadata_renamed + 1)
        end

        set -l final_target (__epub_rename_apply_metadata_name "$out_dir" "$file")
        set -l move_status $status
        if test $move_status -eq 0
            set moved (math $moved + 1)
        else
            set skipped (math $skipped + 1)
            echo "Failed to move $file to $out_dir" >&2
        end
    end

    if test "$moved" -eq 0
        rmdir "$out_dir" 2>/dev/null
        echo "No epub files were moved from $src"
        return 1
    end

    echo "Created $out_dir"
    echo "Moved epub files: $moved"
    if test "$metadata_renamed" -gt 0
        echo "Renamed from metadata: $metadata_renamed"
    end
    if test "$skipped" -gt 0
        echo "Skipped: $skipped"
    end
end
