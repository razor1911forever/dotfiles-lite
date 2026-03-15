function vs --wraps npm --description "starts vue test server"
    tmux rename-session 'vue-'(string trim -c \" (cat package.json | jq .name))
    tmux rename-window -t:1 vite
    tmux send-keys -t 1 "npm run dev -- --host 0.0.0.0" C-m
    tmux split-window -h
    tmux send-keys -t 2 "npx vitest --coverage" C-m
end
