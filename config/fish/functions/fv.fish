function fv --wraps fdfind --description "fdfind |fzf-tmux -p | vi"
    set -l file (fdfind $argv |fzf-tmux -p)
    if test -n "$file"
        vi $file
    end
end
