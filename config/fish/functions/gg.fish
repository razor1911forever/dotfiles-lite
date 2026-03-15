function gg --wraps='git' --description 'git add file contents to index, commits, and pushes'
    argparse --min-args 1 -- $argv
    or return 1
    git add .
    git commit -m (string join ' ' $argv)
    git push
end
