function git_default_branch
    set -l ref (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
    if test $status -eq 0
        basename $ref
        return 0
    end

    # Fallback: check common names
    for branch in main master
        if git rev-parse --verify $branch >/dev/null 2>&1
            echo $branch
            return 0
        end
    end

    return 1
end
