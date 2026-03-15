function fzf_cmd
    argparse --min-args 1 -- $argv
    or return 1

    eval $argv | string split ' ' | fzf-tmux -p | read -l result
    if not test -n "$result"
        return 1
    end
    echo $result
    return 0
end
