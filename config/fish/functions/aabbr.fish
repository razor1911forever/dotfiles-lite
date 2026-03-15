function aabbr --wraps=abbr --description 'creates new abbreviation and adds to ~/.config/fish/conf.d/zzz_abbr.fish'
    argparse --min-args 2 -- $argv
    or begin
        echo "Usage: aabbr <abbreviation> <command> [args...]"
        return 1
    end

    abbr --add -- $argv[1] $argv[2..-1]
    and echo -- abbr --add -- $argv >>~/.config/fish/conf.d/zzz_abbr.fish
end
