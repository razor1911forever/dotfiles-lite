function fishkey --description "swap between default, hybrid, and vi keybindings"
  set switching "Switching to " " hybrid bindings..."
  switch $fish_key_bindings
    case fish_default_key_bindings
      echo "$switching[1]vi$switching[2]"
      vikey
    case fish_vi_key_bindings
      echo "$switching[1]hybrid$switching[2]"
      hybkey
    case fish_hybrid_key_bindings
      echo "$switching[1]default$switching[2]"
      defkey
  end
end
