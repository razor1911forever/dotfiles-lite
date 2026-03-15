function dii
    if set -q argv[1]
        set image (sudo docker images | grep $argv[1] | awk '{print $3}')
        if test ! -z "$image"
            sudo docker inspect $image
        else
            echo "Image $argv[1] not found"
        end
    else
        sudo docker images
    end
end
