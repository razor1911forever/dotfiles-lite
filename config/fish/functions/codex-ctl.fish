function codex-ctl
    set -l profile $argv[1]
    if test -z "$profile"
        echo "Usage: codex-ctl <josh|dev1|personal> [codex args...]" >&2
        return 1
    end

    set -e argv[1]

    if test (count $argv) -gt 0
        switch $argv[1]
            case auto
                set argv[1] --full-auto
            case danger
                set argv[1] --dangerously-bypass-approvals-and-sandbox
            case search
                set argv[1] --search
        end
    end

    set -l codex_home (codex_home_path $profile); or return 1
    mkdir -p $codex_home
    env CODEX_HOME=$codex_home codex $argv
end
