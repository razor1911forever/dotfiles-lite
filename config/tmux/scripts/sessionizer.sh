#!/usr/bin/env bash

action=$1
if [[ "$action" != "session" ]] && [[ "$action" != "window" ]]; then
    return 0
else
    additional=("$HOME/.config/nvim")
    selected=$({
            # depth 1
            fdfind . \
                ~/git \
                ~/OneDrive/stuffs/projects \
                --min-depth 1 --max-depth 1 -td 2> /dev/null;
            # depth 2
            fdfind . \
                ~/src \
                --min-depth 2 --max-depth 2 -td 2> /dev/null;
        } |
        while read -r p; do
            zoxide query -l -s "$p";
        done |
        sort -rnk1 |
        {
            awk '{print $2}';
            for i in "${additional[@]}"; do
                echo "$i";
            done;
            echo "ssh"
        } |
        fzf-tmux -p
    )
fi

if [[ -z $selected ]]; then
    exit 0
fi

if [[ $selected == "ssh" ]]; then
    declare -A hosts_map
    hosts_map=(
        ["appstaging"]="appstaging.dsldhomes.com"
        ["dsld1337"]="dsld1337.dsldhomes.com"
        ["guac"]="dsldremoteclient.dsldhomes.com"
        ["unifi"]="unifi.dsldhomes.com"
        ["webapps1"]="webapps1.dsldhomes.com"
    )

    host=$({
            for i in "${!hosts_map[@]}"; do
                echo "$i";
            done;
        } |
        sort -r |
        fzf-tmux -p
    )

    if [[ -z $host ]]; then
        exit 0
    fi
    host=${hosts_map[$host]}

    selected_name=$(echo "$host" | cut -d. -f1)
else
    selected_name=$(basename "$selected" | tr . _)
fi

if [[ "$action" == "session" ]]; then
    tmux_running=$(pgrep tmux)
    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s "$selected_name" -c "$selected"
        exit 0
    fi

    if ! tmux has-session -t="$selected_name" 2> /dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi
    tmux switch-client -t "$selected_name"
    if [[ "$selected" == "ssh" ]]; then
        tmux send "ssh $host" Enter
    fi
fi
if [[ "$action" == "window" ]]; then
    if [[ "$selected" == "ssh" ]]; then
        tmux new-window -n "$selected_name" "ssh $host"
    else
        tmux new-window -n "$selected_name" -c "$selected"
    fi
fi
