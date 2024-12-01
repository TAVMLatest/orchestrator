#!/bin/bash
set -e

ORGANIZATION="avmupgrades"
REPO_NAME=$1

# Ensure GITHUB_APP_JWT_TOKEN is set
if [ -z "$GITHUB_APP_JWT_TOKEN" ]; then
    echo "Error: GITHUB_APP_JWT_TOKEN environment variable is not set."
    exit 1
fi

# Function to make API calls
github_api_call() {
    curl -s -H "Authorization: token $GITHUB_APP_JWT_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$@"
}

# Check if fork already exists
FORK_EXISTS=$(github_api_call -o /dev/null -w "%{http_code}" \
    "https://api.github.com/repos/${ORGANIZATION}/${REPO_NAME}")

if [ $FORK_EXISTS -eq 200 ]; then
    echo "Fork ${ORGANIZATION}/${REPO_NAME} already exists. Updating..."
    
    # Get default branch of the upstream repo
    UPSTREAM_DEFAULT_BRANCH=$(github_api_call "https://api.github.com/repos/Azure/${REPO_NAME}" | jq -r .default_branch)
    
    # Sync fork with upstream
    SYNC_RESPONSE=$(github_api_call -X POST \
        "https://api.github.com/repos/${ORGANIZATION}/${REPO_NAME}/merge-upstream" \
        -d "{\"branch\": \"${UPSTREAM_DEFAULT_BRANCH}\"}")
    
    SYNC_STATUS=$(echo $SYNC_RESPONSE | jq -r .merged)
    
    if [ "$SYNC_STATUS" = "true" ]; then
        echo "Fork successfully updated."
    else
        echo "Failed to update fork. Response: $SYNC_RESPONSE"
    fi
else
    echo "Creating fork ${ORGANIZATION}/${REPO_NAME}"
    CREATE_RESPONSE=$(github_api_call -X POST \
        "https://api.github.com/repos/Azure/${REPO_NAME}/forks" \
        -d "{\"organization\": \"${ORGANIZATION}\"}")
    
    if [ $? -eq 0 ]; then
        echo "Fork created successfully."
    else
        echo "Failed to create fork. Response: $CREATE_RESPONSE"
    fi
fi