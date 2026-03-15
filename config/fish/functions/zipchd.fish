function zipchd
    mkdir -p zip
    mkdir -p chd

    mv *.zip zip &>/dev/null
    cd zip
    for file in *.zip
        unzip $file &>/dev/null
        rm $file
    end
    for file in *
        chdman createcd -i $file -o (path change-extension '' $file).chd
        rm $file
    end
    for file in *.chd
        mv $file ../chd
    end
    cd ..
end
