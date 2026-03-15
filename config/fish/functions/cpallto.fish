function cpallto --description "Copies all files in cwd to specified directory"
    argparse --min-args 1 -- $argv
    or begin
        echo "Usage: cpallto <directory>"
        return 1
    end
    if not test -d $argv[1]
        mkdir $argv[1]
    end
    for file in (ls -A)
        if test $file != $argv[1]
            cp $file $argv[1]
        end
    end
end
