complete -c git_rename_branch --no-files -a "(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ | string match -v main)"
