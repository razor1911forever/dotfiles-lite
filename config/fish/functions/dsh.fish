function dsh
    if test (count $argv) -lt 1
        set -f cmd sh
    else
        set -f cmd $argv[1]
    end
    dcmd $cmd
end
