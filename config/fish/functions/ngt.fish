function ngt --wraps ng --description "ng testing function"
    if set -q argv[1]
        set spec (fdfind -t f -e spec.ts --max-results 1 --strip-cwd-prefix $argv[1])
        echo $spec
        echo 'ng test --include '$spec
        ng test --code-coverage false --include $spec
    else
        ng test --code-coverage true
    end
end
