function old
    argparse --min-args 1 -- $argv
    or begin
        echo "Usage: $argv[0] <file>"
        return 1
    end

    set file $argv[1]
    if test -f $file
        echo "Copying $file to $file.old"
        cp $file $file.old
    else
        echo "File $file does not exist"
        return 1
    end
end
