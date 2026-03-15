function killport --description 'kills processes running on a port'
    argparse --min-args 1 -- $argv
    or begin
        echo 'usage: killport <port>'
        return 1
    end
    sudo -v
    if test $status -ne 0
        echo 'sudo failed'
        return 1
    end
    set -l pid (sudo lsof -t -i:$argv[1])
    if test -z $pid
        printf "no process running on port %d\n" $argv[1]
        return 1
    end
    sudo kill -9 $pid
    if test $status -ne 0
        printf 'failed to kill %d running on port %d\n' $pid $argv1
        return 1
    end
end
