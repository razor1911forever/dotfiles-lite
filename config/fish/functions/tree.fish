function tree --wraps='ls --all --long' --wraps='eza --all --long --icons --git --octal-permissions --no-permissions --time-style long-iso --classify --tree'
    eza --all --long --icons --git --octal-permissions --no-permissions --time-style long-iso --classify --tree $argv
end
