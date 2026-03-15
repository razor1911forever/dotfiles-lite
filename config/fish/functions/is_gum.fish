function is_gum
    if ! command -v gum &>/dev/null
        echo "gum command not found. Please install it."
        return 1
    end
end
