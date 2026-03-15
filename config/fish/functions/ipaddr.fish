function ipaddr --wraps ipaddr --description "displays ip address for interface"
    if set -q argv[1]
        set devs $argv
    else
        set devs (ip addr | string match -gr '\d: (.*):')
    end
    for dev in $devs
        set ipaddrs (ip addr show dev $dev 2> /dev/null | string match -gr 'inet[6]? (.*)/[\d|\d\d]*')
        echo $dev:
        if test -n "$ipaddrs"
            for ipaddr in $ipaddrs
                echo \t$ipaddr
            end
        end
    end
end
