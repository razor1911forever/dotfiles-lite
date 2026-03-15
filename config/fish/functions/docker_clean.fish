function docker_clean
    echo "Cleaning images..."
    for image in (docker images | grep -v onedrive | awk {'print $3'} | tail -n+2 | tr '\n' ' ' | string split ' ')
        docker rmi -f $image 2>/dev/null
    end
    echo "Pruning system..."
    docker system prune -f
end
