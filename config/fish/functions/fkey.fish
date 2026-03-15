function fkey --description "swap between default, vi, hybrid keybindings"
  set switching "Switching to " " key bindings..."
  switch $fish_key_bindings
    case fish_vi_key_bindings
      fish_hybrid_key_bindings
      echo "$switching[1]hybrid$switching[2]"
    case fish_hybrid_key_bindings
      echo "$switching[1]default$switching[2]"
      fish_default_key_bindings
    case fish_default_key_bindings
      echo "$switching[1]vi$switching[2]"
      fish_vi_key_bindings
  end
end
