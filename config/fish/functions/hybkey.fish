function hybkey --description "hybrid keybindings"
  if test $fish_key_bindings != "fish_hybrid_key_bindings"
    set switching "Switching to " " bindings..."
    echo "$switching[1]hybrid$switching[2]"
    fish_hybrid_key_bindings
  end
end
