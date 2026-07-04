function exsub --description "Submit the current Exercism solution"
    set -l exercise (basename (pwd))
    set -l src_dir src
    set -l file

    if not test -d $src_dir
        echo "exsub: no src directory in "(pwd) >&2
        return 1
    end

    set -l candidates \
        "$src_dir/$exercise.clj" \
        "$src_dir/"(string replace -a '-' '_' -- $exercise)".clj" \
        "$src_dir/$exercise"

    for candidate in $candidates
        if test -f $candidate
            set file $candidate
            break
        end
    end

    if not test -n "$file"
        set file (find $src_dir -type f | sort | fzf-tmux -p)
    end

    if not test -n "$file"
        return 1
    end

    exercism submit $file
end
