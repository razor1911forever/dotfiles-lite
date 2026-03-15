function defkey --description "default keybindings"
    if test $fish_key_bindings != fish_default_key_bindings
        set switching "Switching to " " key bindings..."
        echo "$switching[1]default$switching[2]"
        fish_default_key_bindings
    end
end
