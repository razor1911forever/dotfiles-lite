function vikey --description "vi keybindings"
    if test $fish_key_bindings != fish_vi_key_bindings
        set switching "Switching to " " key bindings..."
        echo "$switching[1]vi$switching[2]"
        fish_vi_key_bindings
    end
end
