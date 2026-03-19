function git_rename_branch
    is_gum || return 1
    git fetch
    set -l old_branch (git rev-parse --abbrev-ref HEAD)
    set -l new_branch (gum input --prompt "New branch name> " --value "$old_branch")

    gum confirm "Are you sure you want to rename '$old_branch' to '$new_branch'?"
    if test $status -ne 0
        return 1
    end
    echo "Renaming branch '$old_branch' to '$new_branch' locally and on remote."

    git branch -m $old_branch $new_branch
    if test $status -ne 0
        echo "Failed to rename local branch"
        return 1
    end
    git push origin :$old_branch
    if test $status -ne 0
        echo "Failed to delete old remote branch. Rolling back local rename."
        git branch -m $new_branch
        return 1
    end
    git push -u origin $new_branch
    if test $status -ne 0
        echo "Failed to push new branch to remote. Rolling back previous steps."
        git push origin $old_branch
        git branch -m $new_branch $old_branch
        return 1
    end
    echo "Renamed branch '$old_branch' to '$new_branch' locally and on remote."
end
