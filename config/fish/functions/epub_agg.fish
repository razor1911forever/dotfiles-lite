function __epub_agg_target --argument-names out_dir name
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

function __epub_agg_move_target --argument-names processed_root name
    set -l target "$processed_root/$name"
    if not test -e "$target"
        echo "$target"
        return 0
    end

    set -l index 2
    while true
        set target "$processed_root/$name-$index"
        if not test -e "$target"
            echo "$target"
            return 0
        end
        set index (math $index + 1)
    end
end

function __epub_agg_ensure_dir --argument-names dir
    if test -d "$dir"
        return 0
    end

    mkdir -p "$dir"
end

function __epub_agg_extract_archive --argument-names archive archive_type dest
    __epub_agg_ensure_dir "$dest"
    or return 1

    switch "$archive_type"
        case zip
            unzip -qq -o "$archive" -d "$dest" 2>/dev/null
        case rar
            unrar x -inul -o+ "$archive" "$dest"/ 2>/dev/null
        case '*'
            return 1
    end
end

function __epub_agg_expand_archive_tree --argument-names archive archive_type
    set -l workspace (mktemp -d)
    or return 1

    __epub_agg_extract_archive "$archive" "$archive_type" "$workspace"
    if test $status -ne 0
        rm -rf "$workspace"
        return 1
    end

    set -l queue (find "$workspace" -type f \( -iname '*.zip' -o -iname '*.rar' \) -print)
    set -l processed
    set -l index 1

    while test $index -le (count $queue)
        set -l nested_archive $queue[$index]
        set index (math $index + 1)

        if contains -- "$nested_archive" $processed
            continue
        end
        set processed $processed "$nested_archive"

        set -l nested_type zip
        if string match -qi '*.rar' -- "$nested_archive"
            set nested_type rar
        end

        set -l nested_parent (path dirname -- "$nested_archive")
        set -l nested_dir (mktemp -d "$nested_parent/.epub_agg_extract.XXXXXX" 2>/dev/null)
        or begin
            echo "Failed to create extraction directory for $nested_archive" >&2
            continue
        end

        if __epub_agg_extract_archive "$nested_archive" "$nested_type" "$nested_dir"
            set queue $queue (find "$nested_dir" -type f \( -iname '*.zip' -o -iname '*.rar' \) -print)
        else
            rm -rf "$nested_dir"
            echo "Failed to extract nested archive $nested_archive from $archive" >&2
        end
    end

    echo "$workspace"
end

function __epub_agg_metadata_name --argument-names file
    set -l function_file (functions --details epub_agg 2>/dev/null)
    if test -z "$function_file"
        return 1
    end

    set -l helper_script (path dirname -- "$function_file")/epub_agg_metadata.py
    if not test -f "$helper_script"
        return 1
    end

    python3 "$helper_script" "$file" 2>/dev/null
end

function __epub_agg_apply_metadata_name --argument-names out_dir file
    set -l metadata_name (__epub_agg_metadata_name "$file")
    if test -z "$metadata_name"
        echo "$file"
        return 0
    end

    if test "$metadata_name" = (basename "$file")
        echo "$file"
        return 0
    end

    set -l target (__epub_agg_target "$out_dir" "$metadata_name")
    if mv "$file" "$target"
        echo "$target"
        return 0
    end

    echo "Failed to rename $file using epub metadata" >&2
    echo "$file"
    return 1
end

function epub_agg --description 'collect epub files from folders and archives into a dated directory'
    if test (count $argv) -gt 1
        echo "Usage: epub_agg [source_dir]"
        return 1
    end

    set -l src .
    if test (count $argv) -eq 1
        set src $argv[1]
    end

    if not test -d "$src"
        echo "Directory not found: $src" >&2
        return 1
    end

    set src (path resolve -- "$src")

    set -l stamp (date +%F)
    set -l out_name "epub_-_$stamp"
    set -l out_dir "$src/$out_name"
    set -l dir_index 2
    set -l processed_root "$src/__processed"

    while test -e "$out_dir"
        set out_name "epub_-_$stamp-$dir_index"
        set out_dir "$src/$out_name"
        set dir_index (math $dir_index + 1)
    end

    set -l root_epubs (find "$src" -mindepth 1 -maxdepth 1 -type f -iname '*.epub' -print)
    set -l root_zip_archives (find "$src" -mindepth 1 -maxdepth 1 -type f -iname '*.zip' -print)
    set -l root_rar_archives (find "$src" -mindepth 1 -maxdepth 1 -type f -iname '*.rar' -print)
    set -l source_dirs (find "$src" -mindepth 1 -maxdepth 1 -type d -not -name '__processed' -not -name 'epub_-_*' -print)

    if test (count $root_epubs) -eq 0; and test (count $root_zip_archives) -eq 0; and test (count $root_rar_archives) -eq 0; and test (count $source_dirs) -eq 0
        echo "Nothing to process in $src"
        return 1
    end

    set -l copied 0
    set -l from_zip 0
    set -l from_rar 0
    set -l skipped 0
    set -l moved_dirs 0
    set -l metadata_renamed 0

    for file in $root_epubs
        __epub_agg_ensure_dir "$out_dir"
        or begin
            echo "Failed to create $out_dir" >&2
            return 1
        end
        set -l target (__epub_agg_target "$out_dir" (basename "$file"))
        if cp "$file" "$target"
            set copied (math $copied + 1)
            set -l final_target (__epub_agg_apply_metadata_name "$out_dir" "$target")
            set -l rename_status $status
            if test $rename_status -eq 0; and test "$final_target" != "$target"
                set metadata_renamed (math $metadata_renamed + 1)
            end
        else
            set skipped (math $skipped + 1)
            echo "Failed to copy $file" >&2
        end
    end

    for archive in $root_zip_archives
        set -l workspace (__epub_agg_expand_archive_tree "$archive" zip)
        if test $status -ne 0
            set skipped (math $skipped + 1)
            echo "Failed to extract $archive" >&2
            continue
        end

        set -l entries (find "$workspace" -type f -iname '*.epub' -print)
        for entry in $entries
            __epub_agg_ensure_dir "$out_dir"
            or begin
                rm -rf "$workspace"
                echo "Failed to create $out_dir" >&2
                return 1
            end
            set -l target (__epub_agg_target "$out_dir" (basename "$entry"))
            if cp "$entry" "$target"
                set from_zip (math $from_zip + 1)
                set -l final_target (__epub_agg_apply_metadata_name "$out_dir" "$target")
                set -l rename_status $status
                if test $rename_status -eq 0; and test "$final_target" != "$target"
                    set metadata_renamed (math $metadata_renamed + 1)
                end
            else
                rm -f "$target"
                set skipped (math $skipped + 1)
                echo "Failed to copy $entry from $archive" >&2
            end
        end

        rm -rf "$workspace"
    end

    for archive in $root_rar_archives
        set -l workspace (__epub_agg_expand_archive_tree "$archive" rar)
        if test $status -ne 0
            set skipped (math $skipped + 1)
            echo "Failed to extract $archive" >&2
            continue
        end

        set -l entries (find "$workspace" -type f -iname '*.epub' -print)
        for entry in $entries
            __epub_agg_ensure_dir "$out_dir"
            or begin
                rm -rf "$workspace"
                echo "Failed to create $out_dir" >&2
                return 1
            end
            set -l target (__epub_agg_target "$out_dir" (basename "$entry"))
            if cp "$entry" "$target"
                set from_rar (math $from_rar + 1)
                set -l final_target (__epub_agg_apply_metadata_name "$out_dir" "$target")
                set -l rename_status $status
                if test $rename_status -eq 0; and test "$final_target" != "$target"
                    set metadata_renamed (math $metadata_renamed + 1)
                end
            else
                rm -f "$target"
                set skipped (math $skipped + 1)
                echo "Failed to copy $entry from $archive" >&2
            end
        end

        rm -rf "$workspace"
    end

    for dir in $source_dirs
        set -l dir_epubs (find "$dir" \( -path '*/epub_-_*' -o -path '*/__processed' \) -prune -o -type f -iname '*.epub' -print)
        set -l dir_zip_archives (find "$dir" \( -path '*/epub_-_*' -o -path '*/__processed' \) -prune -o -type f -iname '*.zip' -print)
        set -l dir_rar_archives (find "$dir" \( -path '*/epub_-_*' -o -path '*/__processed' \) -prune -o -type f -iname '*.rar' -print)

        set -l had_candidates 0
        if test (count $dir_epubs) -gt 0; or test (count $dir_zip_archives) -gt 0; or test (count $dir_rar_archives) -gt 0
            set had_candidates 1
        end

        for file in $dir_epubs
            __epub_agg_ensure_dir "$out_dir"
            or begin
                echo "Failed to create $out_dir" >&2
                return 1
            end
            set -l target (__epub_agg_target "$out_dir" (basename "$file"))
            if cp "$file" "$target"
                set copied (math $copied + 1)
                set -l final_target (__epub_agg_apply_metadata_name "$out_dir" "$target")
                set -l rename_status $status
                if test $rename_status -eq 0; and test "$final_target" != "$target"
                    set metadata_renamed (math $metadata_renamed + 1)
                end
            else
                set skipped (math $skipped + 1)
                echo "Failed to copy $file" >&2
            end
        end

        for archive in $dir_zip_archives
            set -l workspace (__epub_agg_expand_archive_tree "$archive" zip)
            if test $status -ne 0
                set skipped (math $skipped + 1)
                echo "Failed to extract $archive" >&2
                continue
            end

            set -l entries (find "$workspace" -type f -iname '*.epub' -print)
            for entry in $entries
                __epub_agg_ensure_dir "$out_dir"
                or begin
                    rm -rf "$workspace"
                    echo "Failed to create $out_dir" >&2
                    return 1
                end
                set -l target (__epub_agg_target "$out_dir" (basename "$entry"))
                if cp "$entry" "$target"
                    set from_zip (math $from_zip + 1)
                    set -l final_target (__epub_agg_apply_metadata_name "$out_dir" "$target")
                    set -l rename_status $status
                    if test $rename_status -eq 0; and test "$final_target" != "$target"
                        set metadata_renamed (math $metadata_renamed + 1)
                    end
                else
                    rm -f "$target"
                    set skipped (math $skipped + 1)
                    echo "Failed to copy $entry from $archive" >&2
                end
            end

            rm -rf "$workspace"
        end

        for archive in $dir_rar_archives
            set -l workspace (__epub_agg_expand_archive_tree "$archive" rar)
            if test $status -ne 0
                set skipped (math $skipped + 1)
                echo "Failed to extract $archive" >&2
                continue
            end

            set -l entries (find "$workspace" -type f -iname '*.epub' -print)
            for entry in $entries
                __epub_agg_ensure_dir "$out_dir"
                or begin
                    rm -rf "$workspace"
                    echo "Failed to create $out_dir" >&2
                    return 1
                end
                set -l target (__epub_agg_target "$out_dir" (basename "$entry"))
                if cp "$entry" "$target"
                    set from_rar (math $from_rar + 1)
                    set -l final_target (__epub_agg_apply_metadata_name "$out_dir" "$target")
                    set -l rename_status $status
                    if test $rename_status -eq 0; and test "$final_target" != "$target"
                        set metadata_renamed (math $metadata_renamed + 1)
                    end
                else
                    rm -f "$target"
                    set skipped (math $skipped + 1)
                    echo "Failed to copy $entry from $archive" >&2
                end
            end

            rm -rf "$workspace"
        end

        if test "$had_candidates" -eq 1
            __epub_agg_ensure_dir "$processed_root"
            or begin
                echo "Failed to create $processed_root" >&2
                return 1
            end
            set -l processed_target (__epub_agg_move_target "$processed_root" (basename "$dir"))
            if mv "$dir" "$processed_target"
                set moved_dirs (math $moved_dirs + 1)
            else
                set skipped (math $skipped + 1)
                echo "Failed to move $dir to $processed_root" >&2
            end
        end
    end

    set -l total (math $copied + $from_zip + $from_rar)
    if test "$total" -eq 0
        if test -d "$out_dir"
            rmdir "$out_dir" 2>/dev/null
        end
        if test "$moved_dirs" -gt 0
            echo "Moved $moved_dirs directories to $processed_root"
            echo "No epub files found in processed items"
            return 0
        end
        echo "No epub files found inside directories or archives in $src"
        return 1
    end

    echo "Created $out_dir"
    echo "Copied from directories: $copied"
    echo "Extracted from zip files: $from_zip"
    echo "Extracted from rar files: $from_rar"
    if test "$metadata_renamed" -gt 0
        echo "Renamed from metadata: $metadata_renamed"
    end
    if test "$moved_dirs" -gt 0
        echo "Moved directories: $moved_dirs"
    end
    if test "$skipped" -gt 0
        echo "Skipped: $skipped"
    end
end
