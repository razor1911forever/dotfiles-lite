function rm_parent --description "moves all files in cwd to parent directory and removes current directory"
    set cur_dir (basename (pwd))
    set new_dir (random)$cur_dir(random)
    mkdir $new_dir
    for file in (ls -a)
        if test $file != "."; and test $file != ".."; and test $file != $new_dir
            mv $file $new_dir
        end
    end
    mv $new_dir ..
    cd ..
    rm $cur_dir -r
    cd $new_dir
    for file in (ls -a)
        if test $file != "."; and test $file != ".."
            mv $file ..
        end
    end
    cd ..
    rm $new_dir -r
end
