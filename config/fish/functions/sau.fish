function sau --description "updates system"
    set -l nala_exists (which nala)
    if test -n "$nala_exists"
        sudo nala upgrade --update --autoremove --assume-yes
    else
        sudo apt-get update -q
        sudo apt-get upgrade -y -qq
        sudo apt-get autoremove -y -qq
        sudo apt-get clean -y -qq
    end
end
