function git_open_branch
    git pull
    git branch -r | grep -v HEAD | gum filter --prompt "Open branch " --placeholder=(git branch | awk '/\*/ {print $2}') | awk '{print $1}' | sed 's/origin\///' | read -l branch

    echo "Opening branch $branch"

    if test -z "$branch"
        echo "No branch selected."
        return 1
    end

    git checkout $branch
end
