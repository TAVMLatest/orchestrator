#!/bin/bash
set -e

ORGANIZATION="avmupgrades"
REPO_NAME=$1

# Ensure GITHUB_TOKEN is set (changed from GITHUB_APP_JWT_TOKEN)
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    exit 1
fi

# Function to make API calls
github_api_call() {
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
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

# Enable Dependabot alerts
echo "Enabling Dependabot alerts for ${ORGANIZATION}/${REPO_NAME}..."
ALERTS_RESPONSE=$(github_api_call -X PUT \
    "https://api.github.com/repos/${ORGANIZATION}/${REPO_NAME}/vulnerability-alerts")

if [ $? -eq 0 ]; then
    echo "Dependabot alerts enabled successfully."
else
    echo "Failed to enable Dependabot alerts. Response: $ALERTS_RESPONSE"
fi

# Create dependabot.yml file
echo "Creating dependabot.yml file for ${ORGANIZATION}/${REPO_NAME}..."
DEPENDABOT_CONTENT=$(cat <<EOF
version: 2
updates:
  - package-ecosystem: "terraform"
    directory: "/"
    schedule:
      interval: "weekly"
EOF
)

# Encode the content to base64
ENCODED_CONTENT=$(echo "$DEPENDABOT_CONTENT" | base64 -w 0)

# Create or update dependabot.yml file
FILE_RESPONSE=$(github_api_call -X PUT \
    "https://api.github.com/repos/${ORGANIZATION}/${REPO_NAME}/contents/.github/dependabot.yml" \
    -d "{\"message\":\"Create or update dependabot.yml\",\"content\":\"$ENCODED_CONTENT\",\"branch\":\"main\"}")

if [ $? -eq 0 ]; then
    echo "dependabot.yml file created or updated successfully."
else
    echo "Failed to create or update dependabot.yml file. Response: $FILE_RESPONSE"
fi

echo "Dependabot configuration complete for ${ORGANIZATION}/${REPO_NAME}."