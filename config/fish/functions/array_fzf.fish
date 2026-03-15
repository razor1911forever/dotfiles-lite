function array_fzf
    argparse --min-args 1 -- $argv
    or return 1

    set -l arr $argv
    echo $arr | string collect | string split ' ' | fzf-tmux -p | read -l result
    if not test -n "$result"
        return 1
    end
    echo $result
    return 0
end
