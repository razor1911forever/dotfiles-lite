function gurls
    argparse --min-args 1 -- $argv
    or begin
        echo "query is required"
        echo "Usage: gurls <query>"
    end
    set -l query 'GET /search?q='(echo $argv | sed 's/ /+/g')'\n'
    set -l results (printf $query | nc google.com 80 | tidy --custom-tags blocklevel -i 2>/dev/null | awk '/\/url\?q=.*/{print $0}' | sed 's/^[[:blank:]].*"\(.*\)"$/\1/' | sed 's/\/url?q=//' | grep -v google)
    for result in $results
        echo $result
    end
end
