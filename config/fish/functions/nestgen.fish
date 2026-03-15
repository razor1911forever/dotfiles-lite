function nestgen --description "Generates NestJS resources"
    argparse --min-args 1 -- $argv
    or begin
        echo "Please specify a resource name."
        return 1
    end

    set resource $argv[1]

    if test -d $resource
        echo "Resource '$resource' already exists."
        return 1
    end

    # Create directory and navigate into it
    mkdir -p $resource; or return $status
    cd $resource; or return $status

    # Generate NestJS module, controller, and service
    for item in module controller service
        npx nest g $item $resource --flat; or return $status
    end

    # Display directory structure
    tree
end
