#!/bin/bash

# Define the project name
project_name=${1:-$(basename "$(pwd)")}
workspace_folder="/code"

# Retrieve the container ID
HEX_CONFIG=$(printf {\"containerName\":\"/$project_name-dev-container\"} | od -A n -t x1 | tr -d '[\n\t ]')
if [ -z "$HEX_CONFIG" ]; then
    echo "Failed to retrieve the container ID."
    exit 1
fi

echo "Docker container is running with ID $HEX_CONFIG. Attaching to VS Code..."

# Attach to the running container using VS Code
code --folder-uri "vscode-remote://attached-container+$HEX_CONFIG$workspace_folder"
if [ $? -ne 0 ]; then
    echo "Failed to attach VS Code to the container."
    exit 1
fi

echo "Attached to VS Code successfully."