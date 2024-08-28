# based on https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285
# I edited the original one because I found the original one to produce unreliable outputs
# when used with ollama or large diffs
# I added a system prompt to help guide the LLM
# (I'm not an LLM expert, so probably this could be improved)

run_llm() {
    ollama run gitcommit "$1"
}

# Function to read user input compatibly with both Bash and Zsh
read_input() {
    if [ -n "$ZSH_VERSION" ]; then
        echo -n "$1"
        read -r REPLY
    else
        read -p "$1" -r REPLY
    fi
}

# Main script
echo "Generating..."

diff=$(git --no-pager diff --cached)
if [ -z "$diff" ]; then
    echo "No staged changes found. Please stage your changes before committing."
    return 1
fi

prompt="Diff of all staged changes: $diff"

commit_message=$(run_llm "$prompt")

while true; do
    echo "\nProposed commit message:"
    echo "$commit_message"

    read_input "Do you want to (a)ccept, (e)dit, (p)rovide additional context to the LLM, (r)egenerate, or (c)ancel? "
    choice=$REPLY

    case "$choice" in
    a | A)
        if git commit -m "$commit_message"; then
            echo "Changes committed successfully!"
            exit 0
        else
            echo "Commit failed. Please check your changes and try again."
            exit 1
        fi
        ;;
    e | E)
        # Use an editor for multi-line commit messages
        temp_file=$(mktemp)
        echo "$commit_message" >"$temp_file"
        ${EDITOR:-vim} "$temp_file"
        commit_message=$(cat "$temp_file")
        rm "$temp_file"
        if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
            echo "Changes committed successfully with your message!"
            exit 0
        else
            echo "Commit failed. Please check your message and try again."
            exit 1
        fi
        ;;
    p | P)
        read_input "Enter additional context for the LLM: "
        additional_context=$REPLY
        new_prompt="Diff of all staged changes: $diff. Additional context from the developer: $additional_context"
        commit_message=$(run_llm "$new_prompt")
        ;;
    r | R)
        echo "Regenerating commit message..."
        commit_message=$(run_llm "$prompt")
        ;;
    c | C)
        echo "Commit cancelled."
        exit 1
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
    esac
done
