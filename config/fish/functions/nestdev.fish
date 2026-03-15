function nestdev --wraps npm --description "starts nest server"
    argparse --min-args 1 -- $argv
    or return 1
    tmux rename-window -t:1 nest
    tmux rename-session 'nest_'(string trim -c \" (cat package.json | jq .name))'_'$argv[1]
    npm run start:dev $argv[1]
end
