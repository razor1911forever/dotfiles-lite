function codex_home_path
    set -l profile $argv[1]

    switch $profile
        case josh
            echo $HOME/.codex/josh
        case dev1
            echo $HOME/.codex/dev1
        case '*'
            echo "Unknown Codex profile: $profile" >&2
            return 1
    end
end
