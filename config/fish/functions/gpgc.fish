function gpgc --description "creates file from argument, encrypts it as new file, removes old files"
    argparse --min-args 1 -- $argv
    or return 1
    if not test -f $argv[1]
        touch $argv[1]
    end
    gpg -c $argv[1]
    rm $argv[1]
end
