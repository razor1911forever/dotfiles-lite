function dni
    if set -q argv[1]
        set network (sudo docker network list | grep $argv[1] | awk '{print $1}')
        if test ! -z "$network"
            sudo docker network inspect $network
        else
            echo "Network $argv[1] not found"
        end
    end
end
