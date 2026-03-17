function update
    set -l prevd (pwd)
    set -l df ~/git/dotfiles
    if not test -d $df
        set df ~/git/dotfiles-lite
    end
    if not test -d $df
        echo "No dotfiles directory found"
        return 1
    end
    cd $df
    git pull
    make install
    if not set -q NVIM_LIGHTWEIGHT
        gg 'Updated dotfiles'
        nvim_repo_sync
    end
    cd $prevd
end
