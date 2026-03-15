function fzo --wraps fdfind --description "fdfind |fzf-tmux -p | xdg-open"
    set -l file (fdfind $argv | fzf-tmux -p)
    if test -n "$file"
        xdg-open $file &
        disown
    end
end
