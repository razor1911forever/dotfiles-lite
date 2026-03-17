function update
    set -l df ~/git/dotfiles
    set -l prevd (pwd)
    if test -d $df
        cd $df
        git pull
        make install
        gg 'Updated dotfiles'
        nvim_repo_sync
        cd $prevd
    end
end
