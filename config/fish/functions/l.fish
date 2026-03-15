function l --wraps='ls --all --long' --wraps='eza --all --long --icons --git --octal-permissions --no-permissions --time-style long-iso --classify'
    eza --all --long --icons --git --octal-permissions --no-permissions --time-style long-iso --classify $argv
end
