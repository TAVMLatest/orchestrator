#!/bin/bash
set -e

ORGANIZATION="avmupgrades"
REPO_NAME=$1

# Ensure GITHUB_APP_JWT_TOKEN is set
if [ -z "$GITHUB_APP_JWT_TOKEN" ]; then
  echo "Error: GITHUB_APP_JWT_TOKEN environment variable is not set."
  exit 1
fi

# Check if fork already exists
FORK_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token $GITHUB_APP_JWT_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${ORGANIZATION}/${REPO_NAME}")

if [ $FORK_EXISTS -eq 200 ]; then
  echo "Fork ${ORGANIZATION}/${REPO_NAME} already exists. Skipping."
else
  echo "Creating fork ${ORGANIZATION}/${REPO_NAME}"
  curl -X POST \
  -H "Authorization: token $GITHUB_APP_JWT_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/Azure/${REPO_NAME}/forks" \
  -d "{\"organization\": \"${ORGANIZATION}\"}"
fi