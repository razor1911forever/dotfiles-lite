function dcmd --wraps docker --description "Execute docker cmd in container"
    argparse --min-args 1 -- $argv
    or return 1

    set -l cmd $argv[1]
    set -l containers (sudo docker ps -a --format "{{.Names}}")
    if test (count $containers) -lt 1
        echo "No containers found"
        return 1
    end
    set -l container (array_fzf $containers)
    if not test -n "$container"
        echo "No container selected"
        return 1
    end
    set_color bryellow
    echo "Connecting to container: $container"
    sudo docker exec $container which $cmd | read -l cmd_path
    if not test -n "$cmd_path"
        set_color brred
        echo "Command not found in container: $cmd"
        return 1
    end
    set_color brblue
    echo "Executing cmd: $cmd_path"
    set_color normal
    sudo docker exec -it $container $cmd_path
end
