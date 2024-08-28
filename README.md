# git-commit-ollama

This script allows you to generate a commit message for your staged changes using an LLM.

## Installation

1. Install [ollama](https://ollama.com/)

2. Clone the repository

```
git clone https://github.com/mmv08/git-commit-ollama.git
```

3. Create a custom model using the `Modelfile` in this repository

```
ollama create gitcommit -f ./Modelfile
```

4. Add the script to your local executable path

```
cp gcm-llm.sh $HOME/.local/bin/gcm-llm
```
