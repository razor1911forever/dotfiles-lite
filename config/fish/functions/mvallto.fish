function mvallto
    argparse --min-args 1 -- $argv
    or begin
        echo "mvallto: moves all files in current directory to a specified directory."
        echo "Usage: mvallto <directory>"
        return 1
    end
    if not test -d $argv[1]
        mkdir $argv[1]
    end
    for file in (ls -A)
        if test $file != $argv[1]
            mv $file $argv[1]
        end
    end
end
