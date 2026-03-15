function pm
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "This is not a git repository."
        return 1
    end

    set -l branch (git_default_branch)
    if test $status -ne 0
        echo "Error: could not find branch"
        return 1
    end

    set -l current_branch (git branch --show-current)
    set -l did_stash 0

    # Stash dirty state if needed
    if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
        git stash push -q -m "pm: auto-stash"
        set did_stash 1
    end

    if test "$current_branch" != "$branch"
        git checkout $branch
    end

    git pull

    if test $did_stash -eq 1
        git stash pop -q
    end
end
