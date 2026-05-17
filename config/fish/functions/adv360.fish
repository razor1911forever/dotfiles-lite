function adv360 --description 'Manage the Kinesis Advantage360 v-Drive'
    set -l usage 'usage: adv360 [mount|unmount|status|path|cd]'
    set -l label ADV360
    set -l action mount

    if test (count $argv) -gt 1
        echo $usage
        return 1
    end

    if set -q argv[1]
        set action $argv[1]
    end

    if not contains -- $action mount unmount status path cd
        echo $usage
        return 1
    end

    set -l device (lsblk -prno PATH,LABEL | awk '$2 == "ADV360" { print $1; exit }')
    if test -z "$device"
        echo 'ADV360 not detected. Open the keyboard v-Drive first; the LEDs should flash blue.'
        return 1
    end

    set -l mountpoint (findmnt -rn -S $device -o TARGET 2>/dev/null)

    switch $action
        case status
            if test -n "$mountpoint"
                echo "ADV360 mounted at $mountpoint"
            else
                echo "ADV360 detected at $device but not mounted"
            end
        case path
            if test -n "$mountpoint"
                echo $mountpoint
            else
                echo 'ADV360 is not mounted'
                return 1
            end
        case mount cd
            if not type -q udisksctl
                echo 'udisksctl is required but not installed'
                return 1
            end

            if test -z "$mountpoint"
                udisksctl mount -b $device
                or return $status
                set mountpoint (findmnt -rn -S $device -o TARGET 2>/dev/null)
            end

            if test -z "$mountpoint"
                echo "ADV360 mounted but mountpoint could not be determined for $device"
                return 1
            end

            if test $action = cd
                cd -- $mountpoint
            else
                echo $mountpoint
            end
        case unmount
            if not type -q udisksctl
                echo 'udisksctl is required but not installed'
                return 1
            end

            if test -z "$mountpoint"
                echo 'ADV360 is not mounted'
                return 0
            end

            udisksctl unmount -b $device
    end
end
