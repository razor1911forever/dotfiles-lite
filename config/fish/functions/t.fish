function t --wraps tmux --description "connects to active tmux session or creates one"
    if test -n "$TMUX"
        return 1
    end
    tmux ls &>/dev/null
    switch (echo $status)
        case 1
            tmux new -s fish
        case 0
            tmux attach
    end
end
