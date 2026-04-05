function lsshot
    ls -t ~/screenshots/ | head -1 | string replace -r '(.+)' ~/screenshots/'$1'
end
