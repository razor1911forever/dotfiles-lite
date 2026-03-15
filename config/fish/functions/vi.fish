function vi --wraps='/usr/local/bin/nvim'
    if test -x /usr/local/bin/nvim -o -x /usr/bin/nvim -o -x /snap/bin/nvim
        eval (which nvim) $argv
    else
        if test -f ~/.local/bin/nvim.appimage
            ~/.local/bin/nvim.appimage $argv
        end
    end
end
