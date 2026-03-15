function ngs --wraps ngs --description "starts angular test server"
    tmux rename-session 'ng-'(string trim -c \" (cat package.json | jq .name))
    tmux rename-window -t:1 ngs
    set port 4200
    while test (netstat -tunlp 2> /dev/null | grep $port | wc -l) -eq 1
        set port (math $port + 1)
    end
    if set -q argv[1]
        npx ng serve --host 0.0.0.0 --port $port --configuration=$argv[1] --disable-host-check
    else
        npx ng serve --host 0.0.0.0 --port $port
    end
end
