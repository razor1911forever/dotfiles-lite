function tn --wraps tmux --description "start tmux with new session"
    if test (count $argv) -lt 1
        tmux new
    else
        tmux new -s $argv
    end
end
