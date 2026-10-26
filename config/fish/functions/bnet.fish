function bnet --description 'Reset the Lutris/Battle.net/Heroes Wine stack'
    set -l action reset
    if test (count $argv) -gt 0
        set action $argv[1]
    end

    switch $action
        case cleanup stop
            set action reset
    end

    switch $action
        case status
            echo 'Lutris Flatpak instances:'
            set -l instances (command flatpak ps --columns=instance,pid,application 2>/dev/null | string match -r '.*net\.lutris\.Lutris.*')
            if test (count $instances) -eq 0
                echo '  none'
            else
                printf '  %s\n' $instances
            end

            echo 'Battle.net/Heroes windows:'
            if command -sq i3-msg; and command -sq jq
                set -l windows (command i3-msg -t get_tree 2>/dev/null | command jq -r '.. | objects | select(.window? != null) | select(((.window_properties.class // "") | test("battle[.]net|heroes|explorer[.]exe"; "i"))) | "  workspace window: \(.name // "(untitled)") [\(.window_properties.class)]"')
                if test (count $windows) -eq 0
                    echo '  none'
                else
                    printf '%s\n' $windows
                end
            else
                echo '  i3-msg or jq is unavailable'
            end

            echo 'Lutris/Wine helper processes:'
            set -l helpers (command ps -u (id -u) -o pid=,ppid=,stat=,comm=,args= | string match -ri '.*(?:lutris-wrapper|/app/bin/lutris|wineserver|battle[.]net|blizzarderror|heroesofthestorm|explorer[.]exe).*')
            if test (count $helpers) -eq 0
                echo '  none'
            else
                printf '  %s\n' $helpers
            end
            return 0

        case update
            echo 'Updating the system Winetricks installation...'
            command sudo winetricks --self-update
            return $status

        case reset
            echo 'Stopping Lutris and its Wine processes...'

            # This stops every Lutris Flatpak instance, including Wine children
            # whose Linux process names do not resemble their Windows .exe names.
            command flatpak kill net.lutris.Lutris 2>/dev/null

            # Clean up Wine processes left outside (or orphaned from) Flatpak.
            set -l wine_processes \
                wineserver wine wine64 wine-preloader \
                Agent.exe Battle.net.exe BlizzardError.e \
                explorer.exe services.exe plugplay.exe rpcss.exe svchost.exe start.exe

            for process_name in $wine_processes
                command pkill -u (id -u) -TERM -x $process_name 2>/dev/null
            end
            sleep 0.5
            for process_name in $wine_processes
                command pkill -u (id -u) -KILL -x $process_name 2>/dev/null
            end

            # A crashed Flatpak can leave its bwrap process behind even after it
            # disappears from `flatpak ps`. At this point all Lutris instances
            # should be stopped, so matching sandbox wrappers are stale.
            set -l sandbox_pids (command pgrep -u (id -u) -f '^bwrap --args [0-9]+ -- lutris-wrapper$')
            if test (count $sandbox_pids) -gt 0
                command kill -KILL $sandbox_pids 2>/dev/null
            end

            echo 'Lutris/Battle.net/Heroes/Wine reset complete.'
            return 0

        case help -h --help
            echo 'Usage: bnet [status|reset|update]'
            echo '  bnet          Kill the full Lutris/Battle.net/Heroes/Wine stack'
            echo '  bnet status   Show Lutris instances and Battle.net/Heroes windows'
            echo '  bnet reset    Same as bare bnet (cleanup and stop only)'
            echo '  bnet update   Run the old sudo winetricks self-update action'
            return 0

        case '*'
            echo "bnet: unknown action '$action'" >&2
            echo 'Usage: bnet [status|reset|update]' >&2
            return 2
    end
end
