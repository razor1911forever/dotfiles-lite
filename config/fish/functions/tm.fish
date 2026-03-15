function tm --description "Wraps tmux commands to create window layouts"
    set -l profiles $TMUX_PROFILES
    argparse --min-args 1 -- $argv
    or begin
        echo "Profile not found.  Profiles: $profiles"
        return 1
    end
    set -l profile $argv[1]
    switch $profile
        case $profiles[1]
            if test -f angular.json
                tmux send-keys ngs C-m
                tmux new-window
                tmux rename-window -t:2 work
                tmux new-window
            else
                echo "angular.json not found.  Not in an angular directory?"
            end
        case $profiles[2]
            if test -f nest-cli.json
                tmux send-keys "nestdev $argv[2]" C-m
                tmux new-window
                tmux rename-window -t:2 work
                tmux new-window
            else
                echo "nest-cli.json not found.  Not in nestjs directory?"
            end
        case '*'
            echo "Profile not found.  Profiles: $profiles"
    end
end
