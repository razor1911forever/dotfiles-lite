# Fish completion for mage (go build tool)

# Function to get mage targets dynamically
function __mage_targets
    # Check if we're in a directory with a magefile
    if test -f "magefile.go" -o -f "mage.go" -o -f "Magefile.go"
        # Get targets from mage -l, extract just the target names
        mage -l 2>/dev/null | grep -E "^  [a-zA-Z]" | awk '{print $1}' | sort
    end
end

# Complete mage targets
complete -c mage -f -a "(__mage_targets)" -d "Mage target"

# Complete mage flags
complete -c mage -s h -l help -d "Show help"
complete -c mage -s l -l list -d "List mage targets"
complete -c mage -s v -l verbose -d "Show verbose output"
complete -c mage -s d -l dir -r -d "Directory to read magefiles from"
complete -c mage -s f -l file -r -d "Magefile to use"
complete -c mage -s t -l timeout -r -d "Timeout for running mage targets"
complete -c mage -s keep -d "Keep intermediate files"
complete -c mage -s compile -r -d "Output compilation to named binary"
complete -c mage -s ldflags -r -d "Linker flags"
complete -c mage -s gocmd -r -d "Go command to use"
complete -c mage -s debug -d "Turn on debug mode"

