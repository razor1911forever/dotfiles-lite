function node_version
    if test -d node_modules
        set -l n_symbol $__fish_custom_nodejs_prompt_symbol
        set -l n_version (string split 'v' (node -v))[2]
        set_color normal
        set_color $__fish_custom_nodejs_prompt_color
        echo -n $n_symbol $n_version
        set_color normal
    end
end
