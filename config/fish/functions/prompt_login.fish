function prompt_login --description 'Print the user/host portion of the prompt'
    set -l normal (set_color normal)
    set -l user_color (set_color $fish_color_user)
    set -l host_color (set_color $fish_color_host)

    if test -n "$SSH_CONNECTION"
        set host_color (set_color $fish_color_host_remote)
    end

    echo -n -s $user_color (whoami) $normal @ $host_color (prompt_hostname) $normal
end
